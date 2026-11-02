url =
  case System.argv() do
    [value] -> value
    [] -> "http://127.0.0.1:4181/a2a"
  end

{:ok, client} = Arbor.A2A.Client.new(url)

{:ok, count} =
  Arbor.A2A.Client.stream(
    client,
    "SendStreamingMessage",
    %{"message" => Arbor.A2A.Message.text("Hello")},
    0,
    fn event, count ->
      IO.puts(Jason.encode!(event))
      {:cont, count + 1}
    end
  )

IO.puts("STREAM_EXAMPLE_OK #{count}")
