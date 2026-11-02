defmodule Arbor.A2A.Timestamp do
  @moduledoc "Parse ProtoJSON timestamps without losing their nanosecond precision."
  @format ~r/\A(\d{4}-\d{2}-\d{2}[Tt]\d{2}:\d{2}:\d{2})(?:\.(\d{1,9}))?([Zz]|[+-]\d{2}:\d{2})\z/

  @spec parse(term()) :: {:ok, integer()} | {:error, :invalid_timestamp}
  def parse(value) when is_binary(value) do
    with [_, whole, fraction, offset] <- Regex.run(@format, value),
         {:ok, %DateTime{year: year} = time, _} when year in 1..9999 <-
           DateTime.from_iso8601(String.upcase(whole) <> normalize_offset(offset)) do
      nanos = fraction |> String.pad_trailing(9, "0") |> String.to_integer()
      {:ok, DateTime.to_unix(time, :second) * 1_000_000_000 + nanos}
    else
      _ -> {:error, :invalid_timestamp}
    end
  end

  def parse(_), do: {:error, :invalid_timestamp}
  defp normalize_offset("-00:00"), do: "Z"
  defp normalize_offset(offset), do: String.upcase(offset)
end
