defmodule Arbor.A2A.ProtoJSON do
  @moduledoc false
  alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire
  # Protobuf 0.17 treats JSON null in a message-valued oneof as unset,
  # including Part.data's Value null. A validated Part must select content;
  # restore precisely this Value variant after decoding for the binary binding.
  def decode!(map, module) do
    map |> Jason.encode!() |> Protobuf.JSON.decode!(module) |> restore_values()
  end

  defp restore_values(%Wire.Part{content: nil} = part),
    do: %{part | content: {:data, %Google.Protobuf.Value{kind: {:null_value, :NULL_VALUE}}}}

  defp restore_values(%_{} = value) do
    Map.new(Map.to_list(value), fn {key, item} -> {key, restore_values(item)} end)
  end

  defp restore_values(value) when is_list(value), do: Enum.map(value, &restore_values/1)

  defp restore_values(value) when is_tuple(value),
    do: value |> Tuple.to_list() |> Enum.map(&restore_values/1) |> List.to_tuple()

  defp restore_values(value) when is_map(value),
    do: Map.new(Map.to_list(value), fn {key, item} -> {key, restore_values(item)} end)

  defp restore_values(value), do: value
end
