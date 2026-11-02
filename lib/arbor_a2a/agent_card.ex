defmodule Arbor.A2A.AgentCard do
  @moduledoc "A2A 1.0 Agent Card construction and JSON-RPC interface selection."
  alias Arbor.A2A.Message

  def new(name, url, opts \\ []) do
    %{
      "name" => name,
      "description" => Keyword.get(opts, :description, name),
      "version" => Keyword.get(opts, :version, "0.1.0"),
      "supportedInterfaces" => [
        %{"url" => url, "protocolBinding" => "JSONRPC", "protocolVersion" => "1.0"}
      ],
      "capabilities" => %{},
      "defaultInputModes" => ["text/plain"],
      "defaultOutputModes" => ["text/plain"],
      "skills" => Keyword.get(opts, :skills, [])
    }
  end

  def validate(card) when is_map(card) do
    valid =
      Enum.all?(~w(name description version), &Message.nonempty?(card[&1])) and
        match?([_ | _], card["supportedInterfaces"]) and
        Enum.all?(card["supportedInterfaces"], &valid_interface?/1) and
        is_map(card["capabilities"]) and is_list(card["skills"]) and
        Enum.all?(card["skills"], &valid_skill?/1) and
        Enum.all?(~w(defaultInputModes defaultOutputModes), fn k ->
          match?([_ | _], card[k]) and Enum.all?(card[k], &Message.nonempty?/1)
        end)

    if valid, do: :ok, else: {:error, :invalid_agent_card}
  end

  def validate(_), do: {:error, :invalid_agent_card}

  def jsonrpc_interface(card) do
    with :ok <- validate(card),
         interface when is_map(interface) <-
           Enum.find(
             card["supportedInterfaces"],
             &(&1["protocolBinding"] == "JSONRPC" and &1["protocolVersion"] == "1.0")
           ) do
      {:ok, interface}
    else
      nil -> {:error, :unsupported_interface}
      error -> error
    end
  end

  defp valid_interface?(%{
         "url" => url,
         "protocolBinding" => binding,
         "protocolVersion" => version
       }) do
    is_binary(url) and Message.nonempty?(binding) and Message.nonempty?(version) and
      case URI.new(url) do
        {:ok, %URI{scheme: scheme, host: host, userinfo: nil, fragment: nil}} ->
          scheme in ["http", "https"] and Message.nonempty?(host)

        _ ->
          false
      end
  end

  defp valid_interface?(_), do: false

  defp valid_skill?(skill) when is_map(skill),
    do:
      Enum.all?(~w(id name description), &Message.nonempty?(skill[&1])) and is_list(skill["tags"])

  defp valid_skill?(_), do: false
end
