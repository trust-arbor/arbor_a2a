alias Arbor.A2A.{Client, Message}
[base] = System.argv()

for binding <- [:jsonrpc, :rest] do
  path = if binding == :rest, do: "/rest", else: "/a2a"
  {:ok, client} = Client.new(base <> path, binding: binding)
  {:ok, %{"task" => task}} = Client.send_message(client, Message.text("bindings"))
  true = task["status"]["state"] == "TASK_STATE_COMPLETED"
  {:ok, fetched} = Client.get_task(client, task["id"], %{"historyLength" => 0})
  true = fetched["id"] == task["id"]
  {:error, %Arbor.A2A.Error{code: -32_001}} = Client.get_task(client, "missing")

  {:ok, events} =
    Client.stream(
      client,
      "SendStreamingMessage",
      %{"message" => Message.text("stream")},
      [],
      fn event, acc -> {:cont, acc ++ [event]} end
    )

  [%{"task" => streamed}] = events
  true = streamed["status"]["state"] == "TASK_STATE_COMPLETED"
end

IO.puts(Jason.encode!(%{direction: "elixir-bindings-to-sdk", assertions: 8}))
