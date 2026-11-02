defmodule Arbor.A2A.Push do
  @moduledoc """
  Authenticated webhook delivery with bounded retries, response limits and no
  redirects. Destination policies run for registration and every attempt; the
  selected IP is pinned while HTTPS verifies the original hostname. Delivery is
  retried at most three times per outbox job. Configured task-store persistence
  retains the outbox across restarts. Receivers must tolerate duplicate delivery.
  Delivery credentials are never included in
  task events or logs. Supervised worker capacity bounds concurrent deliveries.
  """
  use GenServer
  alias Arbor.A2A.{DestinationPolicy, HTTP, Message, Schema, TaskStore}
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  def wake(store), do: GenServer.cast(__MODULE__, {:wake, store})
  @impl true
  def init(_), do: {:ok, %{waiting: MapSet.new(), workers: %{}}, {:continue, :resume_stores}}
  @impl true
  def handle_continue(:resume_stores, state) do
    Enum.each(Registry.lookup(Arbor.A2A.Stores, :task_store), fn {store, _} -> wake(store) end)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:wake, store}, state) do
    {:noreply, start_workers(%{state | waiting: MapSet.put(state.waiting, store)})}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _}, state) do
    {store, workers} = Map.pop(state.workers, ref)

    waiting =
      if store && Process.alive?(store), do: MapSet.put(state.waiting, store), else: state.waiting

    {:noreply, start_workers(%{state | workers: workers, waiting: waiting})}
  end

  def handle_info({ref, _}, state) when is_reference(ref), do: {:noreply, state}
  def handle_info({:retry_store, store}, state), do: handle_cast({:wake, store}, state)

  defp start_workers(state) when map_size(state.workers) >= 8, do: state

  defp start_workers(state) do
    busy = Map.values(state.workers)
    store = Enum.find(state.waiting, &(&1 not in busy))

    if store do
      waiting = MapSet.delete(state.waiting, store)

      case claim(store) do
        {:ok, id, config, event, opts} ->
          try do
            task =
              Task.Supervisor.async_nolink(Arbor.A2A.Executor, fn ->
                finish_job(store, id, config, event, opts)
              end)

            start_workers(%{
              state
              | workers: Map.put(state.workers, task.ref, store),
                waiting: waiting
            })
          rescue
            _ ->
              Process.send_after(self(), {:retry_store, store}, 100)
              %{state | waiting: waiting}
          end

        _ ->
          start_workers(%{state | waiting: waiting})
      end
    else
      state
    end
  end

  defp finish_job(store, id, config, event, opts) do
    result = deliver(config, event, opts)

    :telemetry.execute(
      [:arbor_a2a, :push, :delivery],
      %{success: if(result == :ok, do: 1, else: 0)},
      %{config_id: config["id"], task_id: config["taskId"]}
    )

    case TaskStore.finish_delivery(store, id) do
      :ok -> :ok
      _ -> Process.sleep(1000)
    end
  catch
    :exit, _ -> :ok
  end

  defp claim(store) do
    TaskStore.next_delivery(store)
  catch
    :exit, _ -> :empty
  end

  def validate(config, opts) do
    with {:ok, bytes} <- Jason.encode(config),
         true <- byte_size(bytes) <= 8192,
         true <- Schema.valid?(Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig, config),
         {:ok, _} <- destination(config["url"], opts),
         {:ok, _} <- headers(config),
         do: :ok,
         else: (_ -> {:error, :invalid_push_config})
  end

  def deliver(config, event, opts \\ []), do: attempt(config, Jason.encode!(event), opts, 0)

  def dispatch(config, event, opts) do
    Task.Supervisor.start_child(Arbor.A2A.Executor, fn -> deliver(config, event, opts) end)
  end

  defp attempt(config, body, opts, number) do
    result =
      with {:ok, address} <- destination(config["url"], opts),
           {:ok, headers} <- headers(config),
           {:ok, response} <-
             HTTP.request(
               "POST",
               config["url"],
               headers ++ [{"content-type", "application/a2a+json"}],
               body,
               connect_address: address,
               timeout: 10_000,
               max_response_bytes: 65_536
             ) do
        classify_response(response.status)
      end

    case result do
      :ok ->
        :ok

      {:error, :untrusted_destination} = error ->
        error

      {:error, :delivery_rejected} = error ->
        error

      _ when number < 2 ->
        Process.sleep(100 * Integer.pow(4, number))
        attempt(config, body, opts, number + 1)

      _ ->
        {:error, :delivery_failed}
    end
  end

  defp classify_response(status) when status in 200..299, do: :ok

  defp classify_response(status) when status == 429 or status >= 500,
    do: {:retry, :remote_failure}

  defp classify_response(_), do: {:error, :delivery_rejected}

  defp destination(url, opts) do
    policy = Keyword.get(opts, :destination_policy, &DestinationPolicy.resolve/1)

    case policy.(url) do
      {:ok, address} when is_tuple(address) -> {:ok, address}
      _ -> {:error, :untrusted_destination}
    end
  rescue
    _ -> {:error, :untrusted_destination}
  end

  defp headers(%{"authentication" => %{"scheme" => scheme, "credentials" => credentials}}) do
    if Message.nonempty?(scheme) and Message.nonempty?(credentials) and
         Regex.match?(~r/^[A-Za-z][A-Za-z0-9_-]*$/, scheme) and
         not String.contains?(credentials, ["\r", "\n"]) do
      {:ok, [{"authorization", scheme <> " " <> credentials}]}
    else
      {:error, :invalid_push_authentication}
    end
  end

  defp headers(config) do
    if Map.has_key?(config, "authentication"),
      do: {:error, :invalid_push_authentication},
      else: {:ok, []}
  end
end
