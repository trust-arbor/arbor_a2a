defmodule Arbor.A2A.SSE do
  @moduledoc """
  Incremental bounded SSE decoder for future streaming transports. This codec
  alone does not enable streaming or task subscriptions on the server/client.
  """
  defstruct buffer: "", data: [], bytes: 0, max_event_bytes: 1_048_576
  def new(opts \\ []), do: struct!(__MODULE__, opts)

  def feed(state, chunk) when is_binary(chunk) do
    parse(state.buffer <> chunk, %{state | buffer: ""}, [])
  end

  def finish(%{buffer: "", data: []}), do: :ok
  def finish(_), do: {:error, :incomplete_event}

  defp parse(bytes, state, events) do
    case :binary.match(bytes, "\n") do
      :nomatch ->
        if state.bytes + byte_size(bytes) <= state.max_event_bytes,
          do: {:ok, Enum.reverse(events), %{state | buffer: bytes}},
          else: {:error, :event_too_large}

      {at, 1} ->
        line = binary_part(bytes, 0, at)
        rest = binary_part(bytes, at + 1, byte_size(bytes) - at - 1)
        parse_line(String.trim_trailing(line, "\r"), rest, state, events)
    end
  end

  defp parse_line("", rest, state, events) do
    events =
      if state.data == [],
        do: events,
        else: [state.data |> Enum.reverse() |> Enum.join("\n") | events]

    parse(rest, %{state | data: [], bytes: 0}, events)
  end

  defp parse_line(line, rest, state, events) do
    if state.bytes + byte_size(line) + 1 > state.max_event_bytes do
      {:error, :event_too_large}
    else
      parse(
        rest,
        %{state | data: append_data(line, state.data), bytes: state.bytes + byte_size(line) + 1},
        events
      )
    end
  end

  defp append_data("data:" <> value, data), do: [String.replace_prefix(value, " ", "") | data]
  defp append_data("data", data), do: ["" | data]
  defp append_data(_, data), do: data
end
