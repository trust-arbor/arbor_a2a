defmodule Arbor.A2A.Events do
  @moduledoc """
  Bounded, pull-based task subscriptions. Slow readers are disconnected with
  `:slow_consumer`; task execution continues. Readers own their subscription,
  and monitor cleanup releases it on disconnect. No event is placed in the
  reader's mailbox until requested. Streams are live, without replay guarantees.
  """
  use GenServer
  @name __MODULE__
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: @name)

  def open(key, snapshot \\ nil, owner \\ self()),
    do: GenServer.call(@name, {:open, key, owner, snapshot})

  def publish(key, event, done \\ false) do
    GenServer.call(@name, {:publish, key, event, done})
  catch
    :exit, _ -> :ok
  end

  def close(ref), do: GenServer.call(@name, {:close, ref, self()})

  def next(ref, timeout \\ 15_000),
    do: GenServer.call(@name, {:next, ref, self(), timeout}, timeout + 1000)

  def enumerable(ref) do
    Stream.resource(fn -> ref end, &read_event/1, &close_stream/1)
  end

  defp read_event(:closed), do: {:halt, :closed}

  defp read_event(ref) do
    case next(ref) do
      {:ok, event} -> {[event], ref}
      :heartbeat -> {[:heartbeat], ref}
      :done -> {:halt, ref}
      {:error, reason} -> {[{:error, reason}], :closed}
    end
  end

  defp close_stream(:closed), do: :ok
  defp close_stream(ref), do: close(ref)

  @impl true
  def format_status(status) do
    status
    |> Map.put(:state, :redacted_subscriptions)
    |> Map.put(:message, :redacted)
    |> Map.put(:log, [])
  end

  @impl true
  def init(opts),
    do:
      {:ok,
       %{
         subscriptions: %{},
         limit: Keyword.get(opts, :queue_limit, 64),
         max: Keyword.get(opts, :max_subscriptions, 1000)
       }}

  @impl true
  def handle_call({:open, key, owner, snapshot}, _, state) do
    if map_size(state.subscriptions) >= state.max do
      {:reply, {:error, :subscription_limit}, state}
    else
      ref = Process.monitor(owner)
      queue = if snapshot, do: :queue.from_list([%{"task" => snapshot}]), else: :queue.new()

      sub = %{
        key: key,
        owner: owner,
        queue: queue,
        count: if(snapshot, do: 1, else: 0),
        waiter: nil,
        done: false,
        error: nil
      }

      {:reply, {:ok, ref}, put_in(state.subscriptions[ref], sub)}
    end
  end

  def handle_call({:publish, key, event, done}, _, state) do
    subs =
      Map.new(state.subscriptions, fn {ref, sub} ->
        sub =
          if sub.key == key and not sub.done,
            do: enqueue(sub, event, done, state.limit),
            else: sub

        {ref, sub}
      end)

    {:reply, :ok, %{state | subscriptions: subs}}
  end

  def handle_call({:next, ref, owner, timeout}, from, state) do
    case state.subscriptions[ref] do
      %{owner: ^owner, waiter: nil} = sub ->
        case :queue.out(sub.queue) do
          {{:value, value}, queue} ->
            {:reply, {:ok, value},
             put_in(state.subscriptions[ref], %{sub | queue: queue, count: sub.count - 1})}

          {:empty, _} when sub.error != nil ->
            {:reply, {:error, sub.error}, remove(state, ref)}

          {:empty, _} when sub.done ->
            {:reply, :done, remove(state, ref)}

          _ ->
            timer = Process.send_after(self(), {:heartbeat, ref}, timeout)
            {:noreply, put_in(state.subscriptions[ref].waiter, {from, timer})}
        end

      _ ->
        {:reply, {:error, :closed_subscription}, state}
    end
  end

  def handle_call({:close, ref, owner}, _, state) do
    case state.subscriptions[ref] do
      %{owner: ^owner} -> {:reply, :ok, remove(state, ref)}
      _ -> {:reply, :ok, state}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _, _}, state), do: {:noreply, remove(state, ref)}

  def handle_info({:heartbeat, ref}, state) do
    case state.subscriptions[ref] do
      %{waiter: {from, _}} ->
        GenServer.reply(from, :heartbeat)
        {:noreply, put_in(state.subscriptions[ref].waiter, nil)}

      _ ->
        {:noreply, state}
    end
  end

  defp enqueue(%{waiter: {from, timer}} = sub, event, done, _) do
    Process.cancel_timer(timer)
    GenServer.reply(from, {:ok, event})
    %{sub | waiter: nil, done: done}
  end

  defp enqueue(%{count: count} = sub, _, _, limit) when count >= limit,
    do: %{sub | queue: :queue.new(), count: 0, done: true, error: :slow_consumer}

  defp enqueue(sub, event, done, _),
    do: %{sub | queue: :queue.in(event, sub.queue), count: sub.count + 1, done: done}

  defp remove(state, ref) do
    case state.subscriptions[ref] do
      %{waiter: {from, timer}} ->
        Process.cancel_timer(timer)
        GenServer.reply(from, :done)

      _ ->
        :ok
    end

    Process.demonitor(ref, [:flush])
    %{state | subscriptions: Map.delete(state.subscriptions, ref)}
  end
end
