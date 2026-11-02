base =
  case System.argv() do
    [value] -> value
    [] -> "http://127.0.0.1:4180"
  end

{:ok, client} = Arbor.A2A.Client.new(base <> "/a2a")

{:ok, %{"task" => task}} =
  Arbor.A2A.Client.send_message(client, Arbor.A2A.Message.text("Hello, A2A"))

IO.puts(Jason.encode!(task, pretty: true))
