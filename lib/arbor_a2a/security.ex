defmodule Arbor.A2A.Security do
  @moduledoc """
  Agent Card security requirement selection. Each requirement is an alternative;
  schemes inside one requirement are conjunctive. Selection never acquires
  credentials, fetches metadata URLs, or interprets ID tokens as access tokens.
  Hosts bind OIDCC provider workers, credentials, scopes and resources to trusted
  configuration, then supply access tokens via `Client`'s token provider.
  """
  def select(card, available) when is_list(available) do
    schemes = Map.get(card, "securitySchemes", %{})
    requirements = Map.get(card, "securityRequirements", [])

    requirement =
      Enum.find(requirements, fn value ->
        is_map(value["schemes"]) and
          Enum.all?(value["schemes"], fn {id, _} ->
            id in available and Map.has_key?(schemes, id)
          end)
      end)

    cond do
      requirements == [] ->
        {:ok, %{}}

      requirement ->
        {:ok,
         Map.new(requirement["schemes"], fn {id, scopes} ->
           {id, %{scheme: schemes[id], scopes: Map.get(scopes, "list", [])}}
         end)}

      true ->
        {:error, :no_supported_security_requirement}
    end
  end
end
