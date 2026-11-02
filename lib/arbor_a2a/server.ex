defmodule Arbor.A2A.Server do
  alias Arbor.A2A.{
    AgentCard,
    Error,
    Events,
    Execution,
    Extensions,
    Message,
    Output,
    Push,
    Request,
    Schema,
    TaskStore
  }

  @moduledoc "A2A JSON-RPC dispatch with a host-supervised, identity-partitioned task store."
  alias Arbor.A2A.Task, as: A2ATask
  @enforce_keys [:handler, :store, :card]
  defstruct [
    :handler,
    :store,
    :card,
    :tenant,
    :extended_card,
    :push,
    :card_updated_at,
    request_extensions: [],
    timeout: 30_000
  ]

  def new(opts) do
    server =
      struct!(__MODULE__, Keyword.put_new_lazy(opts, :card_updated_at, &DateTime.utc_now/0))

    with :ok <- AgentCard.validate(server.card),
         true <-
           is_atom(server.handler) and Code.ensure_loaded?(server.handler) and
             function_exported?(server.handler, :handle_message, 2),
         true <- is_integer(server.timeout) and server.timeout > 0,
         true <- server.card["capabilities"]["pushNotifications"] != true or is_list(server.push),
         true <- valid_extended_card?(server) do
      {:ok, server}
    else
      _ -> {:error, :invalid_server_config}
    end
  rescue
    _ -> {:error, :invalid_server_config}
  end

  def dispatch(server, method, params, principal \\ :anonymous, opts \\ []) when is_map(params) do
    partition = {principal, server.tenant}

    with {:ok, active} <- Extensions.negotiate(server.card, Keyword.get(opts, :extensions, [])),
         server = %{server | request_extensions: active},
         :ok <- available?(server, method),
         {:ok, params} <- Request.normalize(method, params) do
      if valid_tenant?(params, server.tenant),
        do: dispatch_method(server, method, params, partition),
        else: {:error, Error.new(:invalid_params)}
    end
  catch
    :exit, _ -> {:error, Error.new(:internal_error)}
  end

  defp valid_tenant?(params, tenant),
    do:
      Map.get(params, "tenant") == tenant or
        (is_nil(tenant) and Map.get(params, "tenant", "") == "")

  defp dispatch_method(server, "SendMessage", params, partition),
    do: send_message(server, partition, params)

  defp dispatch_method(server, "GetTask", params, partition),
    do: get_task(server, partition, params)

  defp dispatch_method(server, "CancelTask", params, partition),
    do:
      if(TaskStore.owns_worker?(server.store, partition, params["id"]),
        do: TaskStore.cancel(server.store, partition, params["id"]),
        else: cancel_task(server, partition, params)
      )

  defp dispatch_method(server, "ListTasks", params, partition),
    do: TaskStore.list(server.store, partition, params)

  defp dispatch_method(server, "GetExtendedAgentCard", _, partition) do
    if elem(partition, 0) == :anonymous,
      do: {:error, Error.new(:unsupported_operation)},
      else: {:ok, server.extended_card}
  end

  defp dispatch_method(_, method, _, _) when method in ~w(SendStreamingMessage SubscribeToTask),
    do: {:error, Error.new(:unsupported_operation)}

  defp dispatch_method(server, method, params, partition)
       when method in ~w(CreateTaskPushNotificationConfig GetTaskPushNotificationConfig ListTaskPushNotificationConfigs DeleteTaskPushNotificationConfig) do
    if method == "CreateTaskPushNotificationConfig" do
      with {:ok, _} <- TaskStore.get(server.store, partition, params["taskId"]),
           :ok <- Push.validate(params, server.push),
           do: TaskStore.push(server.store, partition, method, params, server.push),
           else: (_ -> {:error, Error.new(:invalid_params)})
    else
      TaskStore.push(server.store, partition, method, params, server.push)
    end
  end

  defp dispatch_method(_, _, _, _), do: {:error, Error.new(:method_not_found)}

  @doc "Persist a task/status/artifact update using identities supplied in the handler context."
  def emit(context, event) do
    with :ok <- Output.event(event, context),
         do:
           TaskStore.emit(
             context.store,
             context.partition,
             context.task_id,
             context.context_id,
             event
           )
  end

  @doc "Open a live task stream. Consume it in the calling process; halt/exit releases the subscription."
  def stream(server, method, params, principal \\ :anonymous, opts \\ []) do
    partition = {principal, server.tenant}

    with {:ok, active} <- Extensions.negotiate(server.card, Keyword.get(opts, :extensions, [])),
         server = %{server | request_extensions: active},
         true <- server.card["capabilities"]["streaming"] == true,
         {:ok, params} <- Request.normalize(method, params),
         true <- valid_tenant?(params, server.tenant) do
      open_stream(server, method, params, partition)
    else
      false -> {:error, Error.new(:unsupported_operation)}
      error -> error
    end
  end

  defp open_stream(server, "SubscribeToTask", params, partition) do
    with {:ok, ref} <- TaskStore.subscribe(server.store, partition, params["id"]),
         do: {:ok, Events.enumerable(ref)}
  end

  defp open_stream(server, "SendStreamingMessage", params, partition) do
    with {:ok, context, config} <- prepare(server, partition, params),
         {:ok, ref} <-
           TaskStore.subscribe(server.store, partition, context.task_id, allow_missing: true) do
      case start_stream_worker(server, params, context, config) do
        {:ok, _} ->
          {:ok, project_stream(Events.enumerable(ref), config["historyLength"])}

        _ ->
          Events.close(ref)
          {:error, Error.new(:internal_error)}
      end
    end
  end

  defp open_stream(_, _, _, _), do: {:error, Error.new(:unsupported_operation)}

  defp start_stream_worker(server, params, context, config),
    do:
      Task.Supervisor.start_child(Arbor.A2A.Executor, fn ->
        produce_stream(server, params, context, config)
      end)

  defp produce_stream(server, params, context, config) do
    result = invoke(server, params, context, Map.put(config, "returnImmediately", true))
    key = {context.store, context.partition, context.task_id}

    case result do
      {:ok, %{"message" => _} = message} -> Events.publish(key, message, true)
      {:ok, _} -> :ok
      {:error, error} -> Events.publish(key, {:error, error}, true)
    end
  end

  defp project_stream(events, history) do
    Stream.map(events, fn
      %{"task" => task} -> %{"task" => A2ATask.project(task, history)}
      event -> event
    end)
  end

  defp send_message(server, partition, params) do
    with {:ok, context, config} <- prepare(server, partition, params),
         do: invoke(server, params, context, config)
  end

  defp prepare(server, partition, params) do
    message = params["message"]
    config = Map.get(params, "configuration", %{})

    with :ok <- Message.validate(message),
         true <- message["role"] == "ROLE_USER",
         :ok <- validate_config(server, config),
         :ok <- supported_parts(message, server.card),
         :ok <- supported_outputs(config, server.card),
         {:ok, prior} <- prior_task(server, partition, message),
         {:ok, context_id} <- context_id(message, prior) do
      {:ok,
       %{
         principal: elem(partition, 0),
         tenant: server.tenant,
         partition: partition,
         extensions: server.request_extensions,
         output_modes:
           server.card["defaultOutputModes"] ++
             Enum.flat_map(server.card["skills"], &Map.get(&1, "outputModes", [])),
         accepted_output_modes: Map.get(config, "acceptedOutputModes", []),
         store: GenServer.whereis(server.store),
         context_id: context_id,
         task_id: if(prior, do: prior["id"], else: Arbor.A2A.id()),
         task: prior
       }, config}
    else
      false -> {:error, Error.new(:invalid_params)}
      error -> error
    end
  end

  defp accept_result(server, partition, %{"task" => task} = result, context, config)
       when map_size(result) == 1 do
    with {:ok, task} <- Schema.normalize(Arbor.A2A.Proto.Lf.A2a.V1.Task, task),
         :ok <- A2ATask.validate(task),
         :ok <- Output.validate(%{"task" => task}, server.card, config),
         true <- task["id"] == context.task_id and task["contextId"] == context.context_id,
         true <-
           config["returnImmediately"] == true or
             task["status"]["state"] in ~w(TASK_STATE_COMPLETED TASK_STATE_FAILED TASK_STATE_CANCELED TASK_STATE_REJECTED TASK_STATE_INPUT_REQUIRED TASK_STATE_AUTH_REQUIRED),
         :ok <- store_task(server, partition, task, config) do
      {:ok, %{"task" => A2ATask.project(task, config["historyLength"])}}
    else
      _ -> {:error, Error.new(:invalid_agent_response)}
    end
  end

  defp accept_result(server, _partition, %{"message" => message} = result, context, config)
       when map_size(result) == 1 do
    with {:ok, message} <- Schema.normalize(Arbor.A2A.Proto.Lf.A2a.V1.Message, message),
         :ok <- Message.validate(message),
         :ok <- Output.validate(%{"message" => message}, server.card, config),
         true <- message["role"] == "ROLE_AGENT" and message["contextId"] == context.context_id,
         true <-
           is_nil(message["taskId"]) or
             (not is_nil(context.task) and message["taskId"] == context.task_id),
         do: {:ok, %{"message" => message}},
         else: (_ -> {:error, Error.new(:invalid_agent_response)})
  end

  defp accept_result(_, _, _, _, _), do: {:error, Error.new(:invalid_agent_response)}

  defp store_task(server, partition, task, %{"taskPushNotificationConfig" => config}) do
    TaskStore.put_with_push(server.store, partition, task, config, server.push)
  end

  defp store_task(server, partition, task, _), do: TaskStore.put(server.store, partition, task)

  defp invoke(server, params, context, config) do
    case run_callback(server, fn -> leased_callback(server, params, context, config) end) do
      {:ok, result} -> result
      _ -> {:error, Error.new(:internal_error)}
    end
  end

  defp leased_callback(server, params, context, config) do
    with {:ok, lease} <-
           TaskStore.claim(server.store, context.partition, context.task_id, context.task) do
      try do
        accept_callback(
          server,
          server.handler.handle_message(params, context),
          context,
          config,
          params
        )
      after
        TaskStore.release(server.store, lease)
      end
    end
  end

  @doc false
  def complete(server, context, response),
    do:
      accept_result(server, context.partition, response, context, %{
        "acceptedOutputModes" => context.accepted_output_modes
      })

  defp accept_callback(server, {:async, fun}, context, config, params) when is_function(fun, 1),
    do: Execution.start(server, params, context, config, fun)

  defp accept_callback(server, {:ok, %{} = response}, context, config, _params) do
    case Jason.encode(response) do
      {:ok, bytes} when byte_size(bytes) <= 1_048_576 ->
        accept_result(server, context.partition, response, context, config)

      _ ->
        {:error, Error.new(:invalid_agent_response)}
    end
  end

  defp accept_callback(_, {:error, %Error{} = error}, _, _, _), do: {:error, error}
  defp accept_callback(_, _, _, _, _), do: {:error, Error.new(:internal_error)}

  defp cancel_task(server, partition, params) do
    with :ok <- valid_id(params),
         {:ok, task} <- TaskStore.get(server.store, partition, params["id"]),
         true <-
           not A2ATask.terminal?(task) and function_exported?(server.handler, :handle_cancel, 2),
         {:ok, :ok} <-
           run_callback(server, fn ->
             server.handler.handle_cancel(task, %{
               principal: elem(partition, 0),
               tenant: server.tenant,
               partition: partition,
               store: server.store
             })
           end) do
      TaskStore.cancel(server.store, partition, params["id"])
    else
      false -> {:error, Error.new(:task_not_cancelable)}
      {:ok, {:error, %Error{} = error}} -> {:error, error}
      {:error, %Error{}} = error -> error
      _ -> {:error, Error.new(:internal_error)}
    end
  end

  defp run_callback(server, callback) do
    task =
      Task.Supervisor.async_nolink(Arbor.A2A.Executor, fn ->
        {:ok, timer} = :timer.kill_after(server.timeout)

        try do
          callback.()
        rescue
          _ -> {:error, Error.new(:internal_error)}
        catch
          _, _ -> {:error, Error.new(:internal_error)}
        after
          :timer.cancel(timer)
        end
      end)

    case Task.yield(task, server.timeout) do
      nil ->
        Task.shutdown(task, :brutal_kill)
        nil

      result ->
        result
    end
  rescue
    _ -> {:error, Error.new(:internal_error)}
  end

  defp prior_task(_server, _partition, message) when not is_map_key(message, "taskId"),
    do: {:ok, nil}

  defp prior_task(server, partition, message) do
    with {:ok, task} <- TaskStore.get(server.store, partition, message["taskId"]),
         false <- A2ATask.terminal?(task),
         do: {:ok, task},
         else: (
           true -> {:error, Error.new(:unsupported_operation)}
           error -> error
         )
  end

  defp context_id(message, nil), do: {:ok, Map.get_lazy(message, "contextId", &Arbor.A2A.id/0)}

  defp context_id(message, task) do
    if is_nil(message["contextId"]) or message["contextId"] == task["contextId"],
      do: {:ok, task["contextId"]},
      else: {:error, Error.new(:invalid_params)}
  end

  defp get_task(server, partition, params) do
    with :ok <- valid_id(params),
         true <- TaskStore.valid_history?(params["historyLength"]),
         {:ok, task} <- TaskStore.get(server.store, partition, params["id"]),
         do: {:ok, A2ATask.project(task, params["historyLength"])},
         else: (
           false -> {:error, Error.new(:invalid_params)}
           error -> error
         )
  end

  defp valid_id(params),
    do: if(Message.nonempty?(params["id"]), do: :ok, else: {:error, Error.new(:invalid_params)})

  defp validate_config(server, config) when is_map(config) do
    cond do
      not TaskStore.valid_history?(config["historyLength"]) ->
        {:error, Error.new(:invalid_params)}

      Map.has_key?(config, "taskPushNotificationConfig") ->
        validate_push_config(server, config["taskPushNotificationConfig"])

      true ->
        :ok
    end
  end

  defp validate_config(_, _), do: {:error, Error.new(:invalid_params)}

  defp validate_push_config(server, config) do
    if server.card["capabilities"]["pushNotifications"] == true do
      case Push.validate(config, server.push) do
        :ok -> :ok
        _ -> {:error, Error.new(:invalid_params)}
      end
    else
      {:error, Error.new(:push_not_supported)}
    end
  end

  defp available?(server, method) do
    cond do
      String.contains?(method, "PushNotification") and
          server.card["capabilities"]["pushNotifications"] != true ->
        {:error, Error.new(:push_not_supported)}

      method == "GetExtendedAgentCard" and is_nil(server.extended_card) ->
        {:error, Error.new(:unsupported_operation)}

      method in ~w(SendStreamingMessage SubscribeToTask) ->
        {:error, Error.new(:unsupported_operation)}

      true ->
        :ok
    end
  end

  defp valid_extended_card?(%{extended_card: nil, card: card}),
    do: card["capabilities"]["extendedAgentCard"] != true

  defp valid_extended_card?(server),
    do:
      AgentCard.validate(server.extended_card) == :ok and
        server.card["capabilities"]["extendedAgentCard"] == true

  defp supported_outputs(config, card) do
    modes = Map.get(config, "acceptedOutputModes", [])

    outputs =
      card["defaultOutputModes"] ++ Enum.flat_map(card["skills"], &Map.get(&1, "outputModes", []))

    if modes == [] or Enum.any?(modes, &(&1 in outputs)),
      do: :ok,
      else: {:error, Error.new(:content_type_not_supported)}
  end

  defp supported_parts(message, card) do
    modes =
      Enum.uniq(
        card["defaultInputModes"] ++ Enum.flat_map(card["skills"], &Map.get(&1, "inputModes", []))
      )

    valid =
      Enum.all?(message["parts"], &(part_media(&1) in modes))

    if valid, do: :ok, else: {:error, Error.new(:content_type_not_supported)}
  end

  defp part_media(%{"mediaType" => type}), do: type
  defp part_media(%{"text" => _}), do: "text/plain"
  defp part_media(%{"data" => _}), do: "application/json"
  defp part_media(_), do: "application/octet-stream"
end
