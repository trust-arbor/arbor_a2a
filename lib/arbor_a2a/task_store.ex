defmodule Arbor.A2A.TaskStore do
  alias Arbor.A2A.{Error, Events, Push, Schema, Task, Timestamp}

  @moduledoc """
  Bounded, process-local task storage partitioned by `{principal, tenant}`.
  Hosts supervise one store per service. Restart discards tasks and page tokens.
  Tokens authenticate the caller/filter binding; pagination is not a snapshot.
  """
  use GenServer
  alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))

  def put(store, partition, task), do: GenServer.call(store, {:put, partition, task})

  def push(store, partition, method, params, opts),
    do: GenServer.call(store, {:push, partition, method, params, opts})

  def put_with_push(store, partition, task, config, opts),
    do: GenServer.call(store, {:put_with_push, partition, task, config, opts})

  def put_managed(store, partition, task, push \\ nil),
    do: GenServer.call(store, {:put_managed, partition, task, push})

  def register_worker(store, partition, id, pid),
    do: GenServer.call(store, {:register_worker, partition, id, pid})

  def owns_worker?(store, partition, id), do: GenServer.call(store, {:owns_worker, partition, id})

  def claim(store, partition, id, expected),
    do: GenServer.call(store, {:claim, partition, id, expected, self()})

  def release(store, ref), do: GenServer.call(store, {:release, ref, self()})
  def next_delivery(store), do: GenServer.call(store, :next_delivery)
  def finish_delivery(store, id), do: GenServer.call(store, {:finish_delivery, id})
  def get(store, partition, id), do: GenServer.call(store, {:get, partition, id})
  def cancel(store, partition, id), do: GenServer.call(store, {:cancel, partition, id})
  def list(store, partition, params \\ %{}), do: GenServer.call(store, {:list, partition, params})

  def subscribe(store, partition, id, opts \\ []),
    do: GenServer.call(store, {:subscribe, partition, id, self(), opts})

  def emit(store, partition, id, context_id, event),
    do: GenServer.call(store, {:emit, partition, id, context_id, event})

  @impl true
  def format_status(status) do
    status
    |> Map.put(:state, :redacted_task_store)
    |> Map.put(:message, :redacted)
    |> Map.put(:log, [])
  end

  @impl true
  def init(opts) do
    limits = %{
      max_tasks: Keyword.get(opts, :max_tasks, 1000),
      ttl_ms: Keyword.get(opts, :ttl_ms, 3_600_000),
      max_task_bytes: Keyword.get(opts, :max_task_bytes, 65_536)
    }

    if Enum.all?(Map.values(limits), &(is_integer(&1) and &1 > 0)),
      do: initialize(limits, opts),
      else: {:stop, :invalid_limits}
  end

  @impl true
  def handle_call(request, _from, state) do
    state = %{
      state
      | tasks: Map.reject(state.tasks, fn {_key, {_task, expires}} -> expires <= now() end)
    }

    state = %{
      state
      | configs: Map.take(state.configs, Map.keys(state.tasks)),
        managed: Enum.filter(state.managed, &Map.has_key?(state.tasks, &1))
    }

    case execute(request, state) do
      {:reply, reply, next} when next != state ->
        next = queue_deliveries(request, state, next)

        commit(request, reply, state, next)

      result ->
        result
    end
  end

  defp commit(request, reply, state, next) do
    case if(length(next.outbox) <= 1000, do: persist(next), else: {:error, :outbox_full}) do
      :ok ->
        notify_changes(request, state.tasks, next.tasks)
        Push.wake(self())
        {:reply, reply, next}

      _ ->
        {:reply, {:error, Error.new(:internal_error)}, state}
    end
  end

  @impl true
  def handle_info(:resume_delivery, state) do
    Push.wake(self())
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _, _}, state) do
    state = %{state | leases: Map.delete(state.leases, ref)}

    case Enum.find(state.workers, fn {_, {_, monitor}} -> monitor == ref end) do
      {key, _} ->
        state = %{state | workers: Map.delete(state.workers, key)}

        fail_worker_task(key, state)

      _ ->
        {:noreply, state}
    end
  end

  defp fail_worker_task(key, state) do
    case state.tasks[key] do
      {task, _} -> fail_active_task(key, task, state)
      _ -> {:noreply, state}
    end
  end

  defp fail_active_task({partition, _}, task, state) do
    if task["status"]["state"] in ~w(TASK_STATE_SUBMITTED TASK_STATE_WORKING) do
      failed =
        Map.put(task, "status", %{
          "state" => "TASK_STATE_FAILED",
          "timestamp" => DateTime.to_iso8601(DateTime.utc_now())
        })

      {:reply, _, next} = handle_call({:put, partition, failed}, nil, state)
      {:noreply, next}
    else
      {:noreply, state}
    end
  end

  defp execute({:put_with_push, partition, task, config, opts}, state) do
    with true <- is_nil(config["taskId"]) or config["taskId"] == task["id"],
         {:reply, :ok, next} <- execute({:put, partition, task}, state),
         {:reply, {:ok, _}, next} <-
           execute(
             {:push, partition, "CreateTaskPushNotificationConfig",
              Map.put(config, "taskId", task["id"]), opts},
             next
           ) do
      {:reply, :ok, next}
    else
      _ -> {:reply, {:error, Error.new(:invalid_params)}, state}
    end
  end

  defp execute({:put_managed, partition, task, push}, state) do
    result =
      case push do
        nil -> execute({:put, partition, task}, state)
        {config, opts} -> execute({:put_with_push, partition, task, config, opts}, state)
      end

    case result do
      {:reply, :ok, next} ->
        {:reply, :ok, %{next | managed: Enum.uniq([{partition, task["id"]} | next.managed])}}

      error ->
        error
    end
  end

  defp execute({:register_worker, partition, id, pid}, state) do
    key = {partition, id}

    if Map.has_key?(state.tasks, key) and not Map.has_key?(state.workers, key) do
      {:reply, :ok, put_in(state.workers[key], {pid, Process.monitor(pid)})}
    else
      {:reply, {:error, :worker_already_registered}, state}
    end
  end

  defp execute({:owns_worker, partition, id}, state),
    do: {:reply, Map.has_key?(state.workers, {partition, id}), state}

  defp execute({:claim, partition, id, expected, owner}, state) do
    key = {partition, id}

    current =
      case state.tasks[key] do
        {task, _} -> task
        _ -> nil
      end

    if current == expected and not Enum.any?(state.leases, fn {_, {k, _}} -> k == key end) do
      ref = Process.monitor(owner)
      {:reply, {:ok, ref}, put_in(state.leases[ref], {key, owner})}
    else
      {:reply, {:error, Error.new(:unsupported_operation)}, state}
    end
  end

  defp execute({:release, ref, owner}, state) do
    case state.leases[ref] do
      {_, ^owner} ->
        Process.demonitor(ref, [:flush])
        {:reply, :ok, %{state | leases: Map.delete(state.leases, ref)}}

      _ ->
        {:reply, :ok, state}
    end
  end

  defp execute(:next_delivery, state) do
    case state.outbox do
      [{id, key, config, event} | _] ->
        {:reply, {:ok, id, config, event, Map.get(state.push_opts, key, state.default_push_opts)},
         state}

      [] ->
        {:reply, :empty, state}
    end
  end

  defp execute({:finish_delivery, id}, state),
    do: {:reply, :ok, %{state | outbox: Enum.reject(state.outbox, &(elem(&1, 0) == id))}}

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
        cancel_stored(partition, id, task, expires, state)
    end
  end

  defp execute({:subscribe, partition, id, owner, opts}, state) do
    snapshot =
      case state.tasks[{partition, id}] do
        {task, _} -> task
        _ -> nil
      end

    reply =
      cond do
        is_nil(snapshot) and not Keyword.get(opts, :allow_missing, false) ->
          {:error, Error.new(:task_not_found)}

        Task.terminal?(snapshot) ->
          {:error, Error.new(:unsupported_operation)}

        true ->
          open_subscription({self(), partition, id}, snapshot, owner)
      end

    {:reply, reply, state}
  end

  defp execute({:emit, partition, id, context_id, event}, state) do
    with {:ok, event} <- Schema.normalize(Wire.StreamResponse, event),
         {:ok, task} <- apply_event(state.tasks[{partition, id}], id, context_id, event),
         {:reply, :ok, next} <- execute({:put, partition, task}, state) do
      {:reply, :ok, next}
    else
      _ -> {:reply, {:error, Error.new(:invalid_agent_response)}, state}
    end
  end

  defp execute({:push, partition, method, params, opts}, state) do
    task_id = params["taskId"]
    key = {partition, task_id}

    if Map.has_key?(state.tasks, key) do
      configs = Map.get(state.configs, key, %{})
      push_operation(method, params, key, configs, opts, state)
    else
      {:reply, {:error, Error.new(:task_not_found)}, state}
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

  defp open_subscription(key, snapshot, owner) do
    case Events.open(key, snapshot, owner) do
      {:ok, _} = result -> result
      _ -> {:error, Error.new(:internal_error)}
    end
  catch
    :exit, _ -> {:error, Error.new(:internal_error)}
  end

  defp cancel_stored(partition, id, task, expires, state) do
    if Task.terminal?(task) do
      {:reply, {:error, Error.new(:task_not_cancelable)}, state}
    else
      task =
        Map.put(task, "status", %{
          "state" => "TASK_STATE_CANCELED",
          "timestamp" => DateTime.to_iso8601(DateTime.utc_now())
        })

      kill_worker(state.workers[{partition, id}])

      {:reply, {:ok, task},
       %{state | tasks: Map.put(state.tasks, {partition, id}, {task, expires})}}
    end
  end

  defp kill_worker({pid, _}), do: Process.exit(pid, :kill)
  defp kill_worker(_), do: :ok

  defp push_operation("CreateTaskPushNotificationConfig", params, key, configs, opts, state) do
    id = Map.get_lazy(params, "id", &Arbor.A2A.id/0)

    if is_binary(id) and id != "" and (Map.has_key?(configs, id) or map_size(configs) < 10) do
      config = Map.put(params, "id", id)

      next =
        state
        |> put_in([:configs, key], Map.put(configs, id, config))
        |> put_in([:push_opts, key], opts)

      {:reply, {:ok, config}, next}
    else
      {:reply, {:error, Error.new(:invalid_params)}, state}
    end
  end

  defp push_operation("ListTaskPushNotificationConfigs", params, key, configs, _, state) do
    size = Map.get(params, "pageSize", 50)

    with true <- is_integer(size) and size in 1..100,
         {:ok, cursor} <- cursor(params, {:push, key}, state.secret) do
      values =
        configs
        |> Map.values()
        |> Enum.sort_by(& &1["id"])
        |> Enum.filter(&(is_nil(cursor) or &1["id"] > elem(cursor, 2)))

      page = Enum.take(values, size)

      next =
        if length(values) > size,
          do: token({0, 0, List.last(page)["id"]}, params, {:push, key}, state.secret),
          else: ""

      {:reply, {:ok, %{"configs" => page, "nextPageToken" => next}}, state}
    else
      _ -> {:reply, {:error, Error.new(:invalid_params)}, state}
    end
  end

  defp push_operation(method, params, key, configs, _, state) do
    case configs[params["id"]] do
      nil -> {:reply, {:error, Error.new(:task_not_found)}, state}
      value when method == "GetTaskPushNotificationConfig" -> {:reply, {:ok, value}, state}
      _ -> {:reply, {:ok, %{}}, put_in(state.configs[key], Map.delete(configs, params["id"]))}
    end
  end

  defp queue_deliveries(request, old, state) do
    jobs =
      Enum.flat_map(state.tasks, fn {key, {task, _}} ->
        if old.tasks[key] != state.tasks[key],
          do: delivery_jobs(request, key, task, state),
          else: []
      end)

    %{state | outbox: state.outbox ++ jobs}
  end

  defp delivery_jobs(request, key, task, state) do
    event =
      case request do
        {:emit, _, _, _, event} -> event
        _ -> %{"task" => task}
      end

    Enum.map(Map.get(state.configs, key, %{}), fn {_, config} ->
      {Arbor.A2A.id(), key, config, event}
    end)
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

  defp initialize(limits, opts) do
    persistence = opts[:persistence]

    loaded =
      case persistence do
        nil -> {:ok, nil}
        {module, config} -> module.load(config)
      end

    with {:ok, snapshot} <- loaded,
         snapshot =
           snapshot ||
             %{
               tasks: %{},
               managed: [],
               outbox: [],
               configs: %{},
               push_opts: %{},
               secret: :crypto.strong_rand_bytes(32)
             },
         true <-
           is_map(snapshot.tasks) and is_binary(snapshot.secret) and
             byte_size(snapshot.secret) == 32,
         true <- map_size(snapshot.tasks) <= limits.max_tasks,
         true <-
           Enum.all?(snapshot.tasks, fn {{_, id}, {task, expires}} ->
             task["id"] == id and Task.validate(task) == :ok and is_integer(expires) and
               byte_size(Jason.encode!(task)) <= limits.max_task_bytes
           end) do
      recovered = recover_managed(snapshot)
      recovered = queue_deliveries(:recovery, snapshot, recovered)
      :ok = persist_recovery(snapshot, recovered, persistence)
      snapshot = recovered
      {:ok, _} = Registry.register(Arbor.A2A.Stores, :task_store, nil)
      send(self(), :resume_delivery)

      {:ok,
       Map.merge(
         limits,
         Map.merge(snapshot, %{
           persistence: persistence,
           push_opts: %{},
           default_push_opts: Keyword.get(opts, :push_options, []),
           leases: %{},
           workers: %{}
         })
       )}
    else
      _ -> {:stop, :invalid_persistence}
    end
  rescue
    _ -> {:stop, :invalid_persistence}
  end

  defp persist_recovery(snapshot, snapshot, _), do: :ok
  defp persist_recovery(_, _, nil), do: :ok

  defp persist_recovery(_, recovered, {module, config}),
    do: module.save(config, Map.take(recovered, [:tasks, :managed, :configs, :outbox, :secret]))

  defp recover_managed(snapshot) do
    tasks =
      Map.new(snapshot.tasks, fn {key, {task, expires}} ->
        task =
          if key in snapshot.managed and
               task["status"]["state"] in ~w(TASK_STATE_SUBMITTED TASK_STATE_WORKING),
             do:
               Map.put(task, "status", %{
                 "state" => "TASK_STATE_FAILED",
                 "timestamp" => DateTime.to_iso8601(DateTime.utc_now())
               }),
             else: task

        {key, {task, expires}}
      end)

    %{snapshot | tasks: tasks}
  end

  defp persist(%{persistence: nil}), do: :ok

  defp persist(%{persistence: {module, config}} = state),
    do: module.save(config, Map.take(state, [:tasks, :managed, :configs, :outbox, :secret]))

  defp notify_changes({:emit, partition, id, _, event}, _old, tasks) do
    {task, _} = tasks[{partition, id}]
    Events.publish({self(), partition, id}, event, Task.terminal?(task))
  end

  defp notify_changes(_, old, tasks) do
    Enum.each(tasks, fn {{partition, id} = key, {task, _}} ->
      previous =
        case old[key] do
          {value, _} -> value
          _ -> nil
        end

      if previous != task, do: publish_change({self(), partition, id}, previous, task)
    end)
  end

  defp publish_change(key, nil, task),
    do: Events.publish(key, %{"task" => task}, Task.terminal?(task))

  defp publish_change({_, _, id} = key, previous, task) do
    Enum.each(Map.get(task, "artifacts", []), &publish_artifact(key, previous, task, &1))

    Events.publish(
      key,
      %{
        "statusUpdate" => %{
          "taskId" => id,
          "contextId" => task["contextId"],
          "status" => task["status"]
        }
      },
      Task.terminal?(task)
    )
  end

  defp publish_artifact({_, _, id} = key, previous, task, artifact) do
    if artifact not in Map.get(previous, "artifacts", []) do
      Events.publish(key, %{
        "artifactUpdate" => %{
          "taskId" => id,
          "contextId" => task["contextId"],
          "artifact" => artifact,
          "lastChunk" => true
        }
      })
    end
  end

  defp apply_event(nil, id, context_id, %{"task" => task}) when map_size(task) > 0 do
    if task["id"] == id and task["contextId"] == context_id, do: {:ok, task}, else: :error
  end

  defp apply_event({task, _}, id, context_id, %{"statusUpdate" => event}) do
    if event["taskId"] == id and event["contextId"] == context_id and
         task["contextId"] == context_id,
       do: {:ok, Map.put(task, "status", event["status"])},
       else: :error
  end

  defp apply_event({task, _}, id, context_id, %{"artifactUpdate" => event}) do
    artifacts = Map.get(task, "artifacts", [])
    artifact = event["artifact"]
    prior = Enum.find(artifacts, &(&1["artifactId"] == artifact["artifactId"]))

    if event["taskId"] == id and event["contextId"] == context_id and
         task["contextId"] == context_id and
         (event["append"] != true or not is_nil(prior)) do
      artifact =
        if event["append"] == true,
          do: Map.put(artifact, "parts", prior["parts"] ++ artifact["parts"]),
          else: artifact

      {:ok,
       Map.put(
         task,
         "artifacts",
         Enum.reject(artifacts, &(&1["artifactId"] == artifact["artifactId"])) ++ [artifact]
       )}
    else
      :error
    end
  end

  defp apply_event(_, _, _, _), do: :error
  defp now, do: System.system_time(:millisecond)
end
