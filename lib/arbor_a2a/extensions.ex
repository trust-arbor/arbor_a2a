defmodule Arbor.A2A.Extensions do
  @moduledoc "Exact-version extension negotiation shared by every binding. Hosts implement the advertised extension semantics."
  alias Arbor.A2A.Error

  def negotiate(card, requested) when is_list(requested) do
    declared = Map.get(card["capabilities"], "extensions", [])

    if Enum.all?(declared, &(&1["required"] != true or &1["uri"] in requested)) do
      {:ok, Enum.filter(declared, &(&1["uri"] in requested)) |> Enum.map(& &1["uri"])}
    else
      {:error, Error.new(:extension_required)}
    end
  end
end
