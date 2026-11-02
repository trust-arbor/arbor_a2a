defmodule Arbor.A2A.ConformanceAgent do
  @moduledoc false
  @behaviour Arbor.A2A.Server.Handler
  alias Arbor.A2A.{Message, Server, Task, TaskStore}
  def handle_cancel(_, _), do: :ok

  def handle_message(params, context) do
    id = params["message"]["messageId"]

    cond do
      String.starts_with?(id, "tck-message-response") or String.starts_with?(id, "tck-stream-002") ->
        {:ok,
         %{
           "message" =>
             Message.text("Direct message response",
               role: "ROLE_AGENT",
               context_id: context.context_id
             )
         }}

      String.starts_with?(id, "tck-stream") ->
        streaming(params, context, id)

      true ->
        complete(params, context, id)
    end
  end

  defp complete(params, context, id) do
    state =
      cond do
        String.starts_with?(id, "tck-input-required") -> "TASK_STATE_INPUT_REQUIRED"
        String.starts_with?(id, "tck-reject-task") -> "TASK_STATE_REJECTED"
        true -> "TASK_STATE_COMPLETED"
      end

    history = if context.task, do: Map.get(context.task, "history", []), else: []

    reply =
      Message.text("Hello from TCK",
        role: "ROLE_AGENT",
        context_id: context.context_id,
        task_id: context.task_id
      )

    task =
      Task.new(context.context_id,
        id: context.task_id,
        state: state,
        history: history ++ [params["message"], reply]
      )

    parts = artifact_parts(id)

    task =
      if parts,
        do: Map.put(task, "artifacts", [%{"artifactId" => "output", "parts" => parts}]),
        else: task

    {:ok, %{"task" => task}}
  end

  defp streaming(params, context, id) do
    task =
      Task.new(context.context_id,
        id: context.task_id,
        state: "TASK_STATE_WORKING",
        history: [params["message"]]
      )

    :ok = Server.emit(context, %{"task" => task})
    parts = artifact_parts(id) || [%{"text" => "Stream hello from TCK"}]

    event = %{
      "taskId" => context.task_id,
      "contextId" => context.context_id,
      "artifact" => %{"artifactId" => "output", "parts" => parts},
      "lastChunk" => true
    }

    :ok = Server.emit(context, %{"artifactUpdate" => event})
    {:ok, stored} = TaskStore.get(context.store, context.partition, context.task_id)
    {:ok, %{"task" => put_in(stored, ["status", "state"], "TASK_STATE_COMPLETED")}}
  end

  defp artifact_parts(id) do
    cond do
      String.contains?(id, "artifact-file-url") ->
        [
          %{
            "url" => "https://example.com/output.txt",
            "filename" => "output.txt",
            "mediaType" => "text/plain"
          }
        ]

      String.contains?(id, "artifact-file") ->
        [
          %{
            "raw" => Base.encode64("file content"),
            "filename" => "output.txt",
            "mediaType" => "text/plain"
          }
        ]

      String.contains?(id, "artifact-data") ->
        [%{"data" => %{"key" => "value", "count" => 42}}]

      String.contains?(id, "artifact-text") ->
        [%{"text" => "Generated text content"}]

      true ->
        nil
    end
  end
end
