defmodule Arbor.A2A.TaskStore do
  @moduledoc """
  Bounded, process-local task storage partitioned by `{principal, tenant}`.
  Hosts supervise one store per service. Restart discards tasks and page tokens.
  Tokens authenticate the caller/filter binding; pagination is not a snapshot.
  """
  use GenServer
  alias Arbor.A2A.{Error, Task, Timestamp}

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))

  def put(store, partition, task), do: GenServer.call(store, {:put, partition, task})
  def get(store, partition, id), do: GenServer.call(store, {:get, partition, id})
  def cancel(store, partition, id), do: GenServer.call(store, {:cancel, partition, id})
  def list(store, partition, params \\ %{}), do: GenServer.call(store, {:list, partition, params})

  @impl true
  def init(opts) do
    limits = %{
      max_tasks: Keyword.get(opts, :max_tasks, 1000),
      ttl_ms: Keyword.get(opts, :ttl_ms, 3_600_000),
      max_task_bytes: Keyword.get(opts, :max_task_bytes, 65_536)
    }

    if Enum.all?(Map.values(limits), &(is_integer(&1) and &1 > 0)),
      do: {:ok, Map.merge(limits, %{tasks: %{}, secret: :crypto.strong_rand_bytes(32)})},
      else: {:stop, :invalid_limits}
  end

  @impl true
  def handle_call(request, _from, state) do
    state = %{
      state
      | tasks: Map.reject(state.tasks, fn {_key, {_task, expires}} -> expires <= now() end)
    }

    execute(request, state)
  end

  defp execute({:put, partition, task}, state) do
    with :ok <- Task.validate(task),
         {:ok, bytes} <- Jason.encode(task),
         true <- byte_size(bytes) <= state.max_task_bytes,
         key = {partition, task["id"]},
         old = state.tasks[key],
         true <- old != nil or map_size(state.tasks) < state.max_tasks,
         true <- compatible?(old, task) do
      tasks = Map.put(state.tasks, key, {task, now() + state.ttl_ms})
      {:reply, :ok, %{state | tasks: tasks}}
    else
      _ -> {:reply, {:error, Error.new(:invalid_agent_response)}, state}
    end
  end

  defp execute({:get, partition, id}, state) do
    reply =
      case state.tasks[{partition, id}] do
        {task, _} -> {:ok, task}
        nil -> {:error, Error.new(:task_not_found)}
      end

    {:reply, reply, state}
  end

  defp execute({:cancel, partition, id}, state) do
    case state.tasks[{partition, id}] do
      nil ->
        {:reply, {:error, Error.new(:task_not_found)}, state}

      {task, expires} ->
        if Task.terminal?(task) do
          {:reply, {:error, Error.new(:task_not_cancelable)}, state}
        else
          task =
            Map.put(task, "status", %{
              "state" => "TASK_STATE_CANCELED",
              "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601()
            })

          {:reply, {:ok, task},
           %{state | tasks: Map.put(state.tasks, {partition, id}, {task, expires})}}
        end
    end
  end

  defp execute({:list, partition, params}, state) do
    with :ok <- validate_list(params),
         {:ok, cursor} <- cursor(params, partition, state.secret) do
      tasks =
        state.tasks
        |> Enum.filter(fn {{owner, _}, {task, _}} ->
          owner == partition and matches?(task, params)
        end)
        |> Enum.map(fn {_, {task, _}} -> task end)
        |> Enum.sort_by(&sort_key/1)

      total = length(tasks)
      size = Map.get(params, "pageSize", 50)
      remaining = Enum.filter(tasks, &(is_nil(cursor) or sort_key(&1) > cursor))
      page = Enum.take(remaining, size)

      next =
        if length(remaining) > size,
          do: token(sort_key(List.last(page)), params, partition, state.secret),
          else: ""

      page = Enum.map(page, &project_task(&1, params))

      {:reply,
       {:ok,
        %{"tasks" => page, "nextPageToken" => next, "pageSize" => size, "totalSize" => total}},
       state}
    else
      _ -> {:reply, {:error, Error.new(:invalid_params)}, state}
    end
  end

  defp project_task(task, params) do
    task = Task.project(task, params["historyLength"])

    if params["includeArtifacts"] == true,
      do: Map.put_new(task, "artifacts", []),
      else: Map.delete(task, "artifacts")
  end

  defp sort_key(task) do
    case task["status"]["timestamp"] do
      nil ->
        {1, 0, task["id"]}

      timestamp ->
        {:ok, time} = Timestamp.parse(timestamp)
        {0, -time, task["id"]}
    end
  end

  defp validate_list(params) do
    size = Map.get(params, "pageSize", 50)

    valid =
      Enum.all?([
        is_integer(size) and size in 1..100,
        valid_history?(params["historyLength"]),
        optional?(params, "includeArtifacts", &is_boolean/1),
        optional?(params, "contextId", &is_binary/1),
        optional?(params, "status", &(&1 in Task.states())),
        valid_time?(params["statusTimestampAfter"]),
        is_binary(Map.get(params, "pageToken", ""))
      ])

    if valid, do: :ok, else: :error
  end

  defp optional?(map, key, validate), do: not Map.has_key?(map, key) or validate.(map[key])

  defp matches?(task, params) do
    (is_nil(params["contextId"]) or task["contextId"] == params["contextId"]) and
      (is_nil(params["status"]) or task["status"]["state"] == params["status"]) and
      after_time?(task["status"]["timestamp"], params["statusTimestampAfter"])
  end

  defp after_time?(_, nil), do: true
  defp after_time?(nil, _), do: false

  defp after_time?(timestamp, cutoff) do
    with {:ok, t} <- Timestamp.parse(timestamp),
         {:ok, c} <- Timestamp.parse(cutoff),
         do: t >= c,
         else: (_ -> false)
  end

  defp valid_time?(nil), do: true

  defp valid_time?(value) when is_binary(value),
    do: match?({:ok, _}, Timestamp.parse(value))

  defp valid_time?(_), do: false
  def valid_history?(nil), do: true
  def valid_history?(n), do: is_integer(n) and n >= 0

  defp compatible?(nil, _task), do: true

  defp compatible?({old, _}, new),
    do: old["contextId"] == new["contextId"] and (not Task.terminal?(old) or old == new)

  defp fingerprint(params, partition),
    do:
      :crypto.hash(:sha256, :erlang.term_to_binary({Map.drop(params, ["pageToken"]), partition}))
      |> Base.url_encode64(padding: false)

  defp token(last, params, partition, secret) do
    body =
      Jason.encode!(%{"last" => Tuple.to_list(last), "binding" => fingerprint(params, partition)})
      |> Base.url_encode64(padding: false)

    body <>
      "." <> (:crypto.mac(:hmac, :sha256, secret, body) |> Base.url_encode64(padding: false))
  end

  defp cursor(params, partition, secret) do
    case Map.get(params, "pageToken", "") do
      "" ->
        {:ok, nil}

      encoded when byte_size(encoded) <= 2048 ->
        with [body, signature] <- String.split(encoded, "."),
             expected =
               :crypto.mac(:hmac, :sha256, secret, body) |> Base.url_encode64(padding: false),
             true <- Plug.Crypto.secure_compare(signature, expected),
             {:ok, json} <- Base.url_decode64(body, padding: false),
             {:ok, %{"last" => [rank, time, id], "binding" => binding}}
             when rank in [0, 1] and is_integer(time) and is_binary(id) <-
               Jason.decode(json),
             true <- binding == fingerprint(params, partition),
             do: {:ok, {rank, time, id}},
             else: (_ -> :error)

      _ ->
        :error
    end
  end

  defp now, do: System.monotonic_time(:millisecond)
end
