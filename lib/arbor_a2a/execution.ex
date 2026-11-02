defmodule Arbor.A2A.Execution do
  @moduledoc """
  Managed execution for handlers returning `{:async, fn context -> result end}`.
  Acknowledgements, polling and streaming share the durable task record. Worker
  timeouts/crashes fail the task; cancellation kills owned work. Restart marks
  abandoned managed tasks failed instead of replaying business side effects.
  """
  alias Arbor.A2A.{Error, Events, Server, TaskStore}
  alias Arbor.A2A.Task, as: A2ATask

  def start(server, params, context, config, fun) do
    task =
      context.task ||
        A2ATask.new(context.context_id, id: context.task_id, history: [params["message"]])

    task =
      if context.task,
        do: Map.update(task, "history", [params["message"]], &(&1 ++ [params["message"]])),
        else: task

    context = %{context | task: task}

    push =
      if config["taskPushNotificationConfig"],
        do: {config["taskPushNotificationConfig"], server.push},
        else: nil

    with :ok <- TaskStore.put_managed(server.store, context.partition, task, push),
         {:ok, pid} <-
           Task.Supervisor.start_child(Arbor.A2A.Executor, fn -> run(server, context, fun) end),
         :ok <- TaskStore.register_worker(server.store, context.partition, task["id"], pid) do
      send(pid, :execute)

      if config["returnImmediately"] == true do
        result(server, context, config)
      else
        wait(server, context, config)
      end
    else
      _ ->
        fail(context)
        {:error, Error.new(:internal_error)}
    end
  end

  defp run(server, context, fun) do
    owner = self()
    spawn_link(fn -> guard_store(context.store, owner) end)

    receive do
      :execute ->
        {:ok, timer} = :timer.kill_after(server.timeout)

        try do
          case fun.(context) do
            {:ok, value} ->
              case Server.complete(server, context, value) do
                {:ok, _} -> :ok
                _ -> fail(context)
              end

            _ ->
              fail(context)
          end
        rescue
          _ -> fail(context)
        catch
          _, _ -> fail(context)
        after
          :timer.cancel(timer)
        end
    after
      5000 -> :registration_timeout
    end
  end

  defp guard_store(store, worker) do
    store_ref = Process.monitor(store)
    worker_ref = Process.monitor(worker)

    receive do
      {:DOWN, ^store_ref, :process, _, _} -> Process.exit(worker, :kill)
      {:DOWN, ^worker_ref, :process, _, _} -> :ok
    end
  end

  defp wait(server, context, config) do
    # Subscribe and inspect atomically: terminal tasks may have completed before this call.
    case TaskStore.subscribe(server.store, context.partition, context.task_id) do
      {:ok, ref} ->
        try do
          await(
            server,
            context,
            config,
            ref,
            System.monotonic_time(:millisecond) + server.timeout
          )
        after
          Events.close(ref)
        end

      {:error, _} ->
        result(server, context, config)
    end
  end

  defp await(server, context, config, ref, deadline) do
    {:ok, task} = TaskStore.get(server.store, context.partition, context.task_id)

    cond do
      A2ATask.terminal?(task) or
          task["status"]["state"] in ~w(TASK_STATE_INPUT_REQUIRED TASK_STATE_AUTH_REQUIRED) ->
        result(server, context, config)

      deadline <= System.monotonic_time(:millisecond) ->
        {:error, Error.new(:internal_error)}

      true ->
        Events.next(ref, min(1000, max(1, deadline - System.monotonic_time(:millisecond))))
        await(server, context, config, ref, deadline)
    end
  end

  defp result(server, context, config) do
    with {:ok, task} <- TaskStore.get(server.store, context.partition, context.task_id),
         do: {:ok, %{"task" => A2ATask.project(task, config["historyLength"])}}
  end

  defp fail(context) do
    with {:ok, task} <- TaskStore.get(context.store, context.partition, context.task_id),
         false <- A2ATask.terminal?(task) do
      TaskStore.put(
        context.store,
        context.partition,
        Map.put(task, "status", %{
          "state" => "TASK_STATE_FAILED",
          "timestamp" => DateTime.to_iso8601(DateTime.utc_now())
        })
      )
    end
  catch
    :exit, _ -> :ok
  end
end
