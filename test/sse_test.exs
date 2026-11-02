defmodule Arbor.A2A.SSETest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Arbor.A2A.SSE

  property "all chunk boundaries preserve SSE data including UTF-8" do
    check all(text <- string(:printable, max_length: 100), split <- integer(0..200)) do
      payload = Jason.encode!(%{"text" => text <> "λ"})
      bytes = "data: " <> payload <> "\r\n\r\n"
      split = min(split, byte_size(bytes))
      left = binary_part(bytes, 0, split)
      right = binary_part(bytes, split, byte_size(bytes) - split)
      assert {:ok, first, state} = SSE.feed(SSE.new(), left)
      assert {:ok, second, state} = SSE.feed(state, right)
      assert first ++ second == [payload]
      assert :ok = SSE.finish(state)
    end
  end

  test "multiline events, empty data, comments and incomplete events" do
    assert {:ok, ["one\ntwo", ""], state} =
             SSE.feed(SSE.new(), ": comment\ndata: one\ndata:two\n\ndata\n\n")

    assert :ok = SSE.finish(state)
    assert {:ok, [], state} = SSE.feed(state, "data: partial")
    assert {:error, :incomplete_event} = SSE.finish(state)
  end

  test "enforces limits for accumulated lines and unterminated chunks" do
    assert {:error, :event_too_large} = SSE.feed(SSE.new(max_event_bytes: 8), "data: 1234\n")
    assert {:ok, [], state} = SSE.feed(SSE.new(max_event_bytes: 8), "data:")
    assert {:error, :event_too_large} = SSE.feed(state, "1234")
  end
end
