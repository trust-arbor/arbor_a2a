[base] = System.argv()
{:ok, card} = Arbor.A2A.Client.discover(base)
{:ok, client} = Arbor.A2A.Client.new(base <> "/a2a")

{:ok, %{"task" => task}} =
  Arbor.A2A.Client.send_message(client, Arbor.A2A.Message.text("Elixir peer"))

true = task["status"]["state"] == "TASK_STATE_COMPLETED"
true = List.last(task["history"])["parts"] == [%{"text" => "SDK: Elixir peer"}]
{:ok, fetched} = Arbor.A2A.Client.get_task(client, task["id"])
true = fetched["id"] == task["id"]
{:ok, listed} = Arbor.A2A.Client.list_tasks(client)
true = Enum.any?(listed["tasks"], &(&1["id"] == task["id"]))
{:error, %Arbor.A2A.Error{code: -32001}} = Arbor.A2A.Client.get_task(client, "missing")
true = card["name"] == "Official SDK Echo"

IO.puts(
  Jason.encode!(%{
    direction: "elixir-client-to-sdk",
    peer: "@a2a-js/sdk",
    version: "1.3.0",
    assertions: 6
  })
)
