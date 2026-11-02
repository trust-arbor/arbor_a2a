defmodule Arbor.A2A do
  @moduledoc """
  A2A 1.0 JSON-RPC foundations. See `Arbor.A2A.Client`, `Arbor.A2A.Server`,
  `Arbor.A2A.HttpPlug` and `Arbor.A2A.TaskStore`.
  """
  @spec protocol_version() :: String.t()
  def protocol_version, do: "1.0"

  @doc "A fresh, opaque server-generated identifier."
  def id, do: :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
end
