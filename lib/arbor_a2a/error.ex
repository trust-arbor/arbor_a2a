defmodule Arbor.A2A.Error do
  @moduledoc "Typed errors with A2A 1.0 JSON-RPC code and ErrorInfo mappings."
  defexception [:code, :message, :data]
  @type t :: %__MODULE__{code: integer(), message: String.t(), data: list() | nil}
  @errors %{
    parse_error: {-32_700, "Invalid JSON payload"},
    invalid_request: {-32_600, "Request payload validation error"},
    method_not_found: {-32_601, "Method not found"},
    invalid_params: {-32_602, "Invalid parameters"},
    internal_error: {-32_603, "Internal error"},
    task_not_found: {-32_001, "TaskNotFoundError"},
    task_not_cancelable: {-32_002, "TaskNotCancelableError"},
    push_not_supported: {-32_003, "PushNotificationNotSupportedError"},
    unsupported_operation: {-32_004, "UnsupportedOperationError"},
    content_type_not_supported: {-32_005, "ContentTypeNotSupportedError"},
    invalid_agent_response: {-32_006, "InvalidAgentResponseError"},
    extended_card_not_configured: {-32_007, "ExtendedAgentCardNotConfiguredError"},
    extension_required: {-32_008, "ExtensionSupportRequiredError"},
    version_not_supported: {-32_009, "VersionNotSupportedError"}
  }

  @spec new(atom()) :: t()
  def new(kind) do
    {code, message} = Map.fetch!(@errors, kind)

    data =
      if code in -32_009..-32_001 do
        [
          %{
            "@type" => "type.googleapis.com/google.rpc.ErrorInfo",
            "reason" =>
              message
              |> String.replace_suffix("Error", "")
              |> Macro.underscore()
              |> String.upcase(),
            "domain" => "a2a-protocol.org"
          }
        ]
      end

    %__MODULE__{code: code, message: message, data: data}
  end

  @doc false
  def from_reason(reason) do
    key =
      Enum.find_value(@errors, fn {key, _} ->
        error = new(key)
        if error.data && hd(error.data)["reason"] == reason, do: key
      end)

    new(key || :internal_error)
  end

  def to_map(%__MODULE__{} = error) do
    map = %{"code" => error.code, "message" => error.message}
    if error.data, do: Map.put(map, "data", error.data), else: map
  end
end
