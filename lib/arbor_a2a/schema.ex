defmodule Arbor.A2A.Schema do
  @moduledoc """
  Schema-aware ProtoJSON parsing using types generated from the pinned canonical
  proto. Accepts protobuf and JSON field names, numeric enum values, integer
  strings, null/unset fields and both base64 alphabets. Struct/Value dictionaries
  retain their keys. Unknown fields are ignored for forward compatibility; ambiguous alternate spellings fail closed.
  Semantic constraints (roles, state transitions, identity and media negotiation)
  remain in the protocol layer.
  """
  alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire

  @requests %{
    "SendMessage" => Wire.SendMessageRequest,
    "SendStreamingMessage" => Wire.SendMessageRequest,
    "GetTask" => Wire.GetTaskRequest,
    "ListTasks" => Wire.ListTasksRequest,
    "CancelTask" => Wire.CancelTaskRequest,
    "SubscribeToTask" => Wire.SubscribeToTaskRequest,
    "CreateTaskPushNotificationConfig" => Wire.TaskPushNotificationConfig,
    "GetTaskPushNotificationConfig" => Wire.GetTaskPushNotificationConfigRequest,
    "ListTaskPushNotificationConfigs" => Wire.ListTaskPushNotificationConfigsRequest,
    "DeleteTaskPushNotificationConfig" => Wire.DeleteTaskPushNotificationConfigRequest,
    "GetExtendedAgentCard" => Wire.GetExtendedAgentCardRequest
  }
  @responses %{
    "SendMessage" => Wire.SendMessageResponse,
    "GetTask" => Wire.Task,
    "CancelTask" => Wire.Task,
    "ListTasks" => Wire.ListTasksResponse,
    "CreateTaskPushNotificationConfig" => Wire.TaskPushNotificationConfig,
    "GetTaskPushNotificationConfig" => Wire.TaskPushNotificationConfig,
    "ListTaskPushNotificationConfigs" => Wire.ListTaskPushNotificationConfigsResponse,
    "DeleteTaskPushNotificationConfig" => Google.Protobuf.Empty,
    "GetExtendedAgentCard" => Wire.AgentCard
  }

  def request_type(method), do: @requests[method]
  def response_type(method), do: @responses[method]

  def normalize(module, value) do
    with {:ok, normalized} <- object(module, value, 0),
         {:ok, encoded} <- Jason.encode(normalized),
         {:ok, _} <- Protobuf.JSON.decode(encoded, module, recursion_limit: 64) do
      {:ok, normalized}
    else
      _ -> {:error, :invalid_proto_json}
    end
  rescue
    _ -> {:error, :invalid_proto_json}
  end

  def valid?(module, value), do: match?({:ok, _}, normalize(module, value))

  defp object(_, _, depth) when depth > 64, do: :error

  defp object(module, value, depth) when is_map(value) and not is_struct(value) do
    fields = module.__message_props__().field_props |> Map.values()

    with true <- unambiguous_fields?(value, fields),
         {:ok, normalized} <- normalize_fields(value, fields, depth),
         true <- required?(module, normalized),
         true <- oneofs?(fields, normalized) do
      {:ok, normalized}
    else
      _ -> :error
    end
  end

  defp object(_, _, _), do: :error

  defp unambiguous_fields?(value, fields),
    do:
      Enum.all?(fields, fn field ->
        field.name == field.json_name or
          not (Map.has_key?(value, field.name) and Map.has_key?(value, field.json_name))
      end)

  defp normalize_fields(value, fields, depth) do
    Enum.reduce_while(value, {:ok, %{}}, fn {key, value}, {:ok, acc} ->
      field = Enum.find(fields, &(key in [&1.name, &1.json_name]))
      normalize_field(field, value, acc, depth)
    end)
  end

  defp normalize_field(nil, _, acc, _), do: {:cont, {:ok, acc}}

  defp normalize_field(field, value, acc, depth) do
    cond do
      Map.has_key?(acc, field.json_name) -> {:halt, :error}
      is_nil(value) and field.type != Google.Protobuf.Value -> {:cont, {:ok, acc}}
      true -> normalize_value(field, value, acc, depth)
    end
  end

  defp normalize_value(field, value, acc, depth) do
    case field_value(field, value, depth + 1) do
      {:ok, normalized} -> {:cont, {:ok, Map.put(acc, field.json_name, normalized)}}
      _ -> {:halt, :error}
    end
  end

  defp field_value(%{map?: true, type: module}, values, depth) when is_map(values) do
    prop = module.__message_props__().field_props[2]

    Enum.reduce_while(values, {:ok, %{}}, fn {k, v}, {:ok, acc} ->
      case field_value(prop, v, depth) do
        {:ok, v} when is_binary(k) -> {:cont, {:ok, Map.put(acc, k, v)}}
        _ -> {:halt, :error}
      end
    end)
  end

  defp field_value(%{repeated?: true} = field, values, depth) when is_list(values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, acc} ->
      case field_value(%{field | repeated?: false}, value, depth) do
        {:ok, normalized} when not is_nil(value) -> {:cont, {:ok, [normalized | acc]}}
        _ -> {:halt, :error}
      end
    end)
    |> reverse()
  end

  defp field_value(%{type: type}, value, _)
       when type in [Google.Protobuf.Struct, Google.Protobuf.Value],
       do: if(json?(value, 0), do: {:ok, value}, else: :error)

  defp field_value(%{type: Google.Protobuf.Timestamp}, value, _) do
    if match?({:ok, _}, Arbor.A2A.Timestamp.parse(value)), do: {:ok, value}, else: :error
  end

  defp field_value(%{embedded?: true, type: module}, value, depth),
    do: object(module, value, depth)

  defp field_value(%{type: {:enum, _}}, value, _) when is_atom(value),
    do: {:ok, Atom.to_string(value)}

  defp field_value(%{type: {:enum, module}}, value, _) when is_integer(value),
    do: {:ok, module.key(value) |> Atom.to_string()}

  defp field_value(%{type: :int32}, value, _) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} -> {:ok, n}
      _ -> :error
    end
  end

  defp field_value(%{type: :bytes}, value, _) when is_binary(value) do
    value =
      String.replace(value, ["-", "_"], fn
        "-" -> "+"
        "_" -> "/"
      end)

    case Base.decode64(value, padding: false) do
      {:ok, bytes} -> {:ok, Base.encode64(bytes)}
      _ -> :error
    end
  end

  defp field_value(_, value, _), do: {:ok, value}
  defp reverse({:ok, values}), do: {:ok, Enum.reverse(values)}
  defp reverse(other), do: other

  defp required?(module, value) do
    if function_exported?(module, :descriptor, 0) do
      Enum.all?(module.descriptor().field, fn field ->
        opts = field.options

        required =
          not is_nil(opts) and Enum.any?(opts.__unknown_fields__, &(&1 == {1052, 2, <<2>>}))

        not required or Map.has_key?(value, field.json_name)
      end)
    else
      true
    end
  end

  defp oneofs?(fields, value) do
    fields
    |> Enum.reject(&is_nil(&1.oneof))
    |> Enum.group_by(& &1.oneof)
    |> Enum.all?(fn {_, group} -> Enum.count(group, &Map.has_key?(value, &1.json_name)) <= 1 end)
  end

  defp json?(_, depth) when depth > 64, do: false

  defp json?(value, _)
       when is_binary(value) or is_boolean(value) or is_nil(value) or is_number(value) do
    true
  end

  defp json?(values, depth) when is_list(values), do: Enum.all?(values, &json?(&1, depth + 1))

  defp json?(value, depth) when is_map(value) and not is_struct(value),
    do: Enum.all?(value, fn {k, v} -> is_binary(k) and json?(v, depth + 1) end)

  defp json?(_, _), do: false
end
