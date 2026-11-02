defmodule Arbor.A2A.Server do
  @moduledoc "A2A JSON-RPC dispatch with a host-supervised, identity-partitioned task store."
  alias Arbor.A2A.{AgentCard, Error, Message, Request, TaskStore}
  alias Arbor.A2A.Task, as: A2ATask
  @enforce_keys [:handler, :store, :card]
  defstruct [:handler, :store, :card, :tenant, timeout: 30_000]

  def new(opts) do
    server = struct!(__MODULE__, opts)

    with :ok <- AgentCard.validate(server.card),
         true <-
           is_atom(server.handler) and Code.ensure_loaded?(server.handler) and
             function_exported?(server.handler, :handle_message, 2),
         true <- is_integer(server.timeout) and server.timeout > 0,
         false <-
           Enum.any?(
             ~w(streaming pushNotifications extendedAgentCard),
             &(server.card["capabilities"][&1] == true)
           ),
         false <-
           Enum.any?(
             Map.get(server.card["capabilities"], "extensions", []),
             &(&1["required"] == true)
           ) do
      {:ok, server}
    else
      _ -> {:error, :invalid_server_config}
    end
  rescue
    _ -> {:error, :invalid_server_config}
  end

  def dispatch(server, method, params, principal \\ :anonymous) when is_map(params) do
    partition = {principal, server.tenant}

    with {:ok, params} <- Request.normalize(method, params) do
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
    do: cancel_task(server, partition, params)

  defp dispatch_method(server, "ListTasks", params, partition),
    do: TaskStore.list(server.store, partition, params)

  defp dispatch_method(_, method, _, _)
       when method in ~w(SendStreamingMessage SubscribeToTask GetExtendedAgentCard),
       do: {:error, Error.new(:unsupported_operation)}

  defp dispatch_method(_, method, _, _)
       when method in ~w(CreateTaskPushNotificationConfig GetTaskPushNotificationConfig ListTaskPushNotificationConfigs DeleteTaskPushNotificationConfig),
       do: {:error, Error.new(:push_not_supported)}

  defp dispatch_method(_, _, _, _), do: {:error, Error.new(:method_not_found)}

  defp send_message(server, partition, params) do
    message = params["message"]
    config = Map.get(params, "configuration", %{})

    with :ok <- Message.validate(message),
         true <- message["role"] == "ROLE_USER",
         :ok <- validate_config(config),
         :ok <- supported_parts(message, server.card),
         {:ok, prior} <- prior_task(server, partition, message),
         {:ok, context_id} <- context_id(message, prior),
         context = %{
           principal: elem(partition, 0),
           tenant: server.tenant,
           partition: partition,
           store: server.store,
           context_id: context_id,
           task_id: if(prior, do: prior["id"], else: Arbor.A2A.id()),
           task: prior
         },
         {:ok, result} <- invoke(server, params, context),
         {:ok, result} <- accept_result(server, partition, result, context, config) do
      {:ok, result}
    else
      false -> {:error, Error.new(:invalid_params)}
      error -> error
    end
  end

  defp accept_result(server, partition, %{"task" => task} = result, context, config)
       when map_size(result) == 1 do
    with :ok <- A2ATask.validate(task),
         true <- task["id"] == context.task_id and task["contextId"] == context.context_id,
         true <-
           config["returnImmediately"] == true or
             task["status"]["state"] in ~w(TASK_STATE_COMPLETED TASK_STATE_FAILED TASK_STATE_CANCELED TASK_STATE_REJECTED TASK_STATE_INPUT_REQUIRED TASK_STATE_AUTH_REQUIRED),
         :ok <- TaskStore.put(server.store, partition, task) do
      {:ok, %{"task" => A2ATask.project(task, config["historyLength"])}}
    else
      _ -> {:error, Error.new(:invalid_agent_response)}
    end
  end

  defp accept_result(_server, _partition, %{"message" => message} = result, context, _config)
       when map_size(result) == 1 do
    with :ok <- Message.validate(message),
         true <- message["role"] == "ROLE_AGENT" and message["contextId"] == context.context_id,
         true <-
           is_nil(message["taskId"]) or
             (not is_nil(context.task) and message["taskId"] == context.task_id),
         do: {:ok, result},
         else: (_ -> {:error, Error.new(:invalid_agent_response)})
  end

  defp accept_result(_, _, _, _, _), do: {:error, Error.new(:invalid_agent_response)}

  defp invoke(server, params, context) do
    case run_callback(server, fn -> server.handler.handle_message(params, context) end) do
      {:ok, {:ok, %{} = response}} ->
        case Jason.encode(response) do
          {:ok, bytes} when byte_size(bytes) <= 1_048_576 -> {:ok, response}
          _ -> {:error, Error.new(:invalid_agent_response)}
        end

      {:ok, {:error, %Error{} = error}} ->
        {:error, error}

      _ ->
        {:error, Error.new(:internal_error)}
    end
  end

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

  defp validate_config(config) when is_map(config) do
    cond do
      Map.has_key?(config, "taskPushNotificationConfig") ->
        {:error, Error.new(:push_not_supported)}

      not TaskStore.valid_history?(config["historyLength"]) ->
        {:error, Error.new(:invalid_params)}

      Map.has_key?(config, "returnImmediately") and not is_boolean(config["returnImmediately"]) ->
        {:error, Error.new(:invalid_params)}

      Map.has_key?(config, "acceptedOutputModes") and
          (not is_list(config["acceptedOutputModes"]) or
             not Enum.all?(config["acceptedOutputModes"], &is_binary/1)) ->
        {:error, Error.new(:invalid_params)}

      true ->
        :ok
    end
  end

  defp validate_config(_), do: {:error, Error.new(:invalid_params)}

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
