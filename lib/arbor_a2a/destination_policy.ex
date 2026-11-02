defmodule Arbor.A2A.DestinationPolicy do
  @moduledoc """
  Public-network webhook policy. Resolve before each attempt and pin the checked
  address for the connection while retaining the URL host for TLS/SNI and Host.
  Reject private, loopback, link-local, multicast, documentation and transition
  ranges. Trusted private deployments can explicitly supply a different policy
  returning `{:ok, address}`; never derive that policy from an untrusted card.
  """
  import Bitwise
  alias Arbor.A2A.HTTP

  @nonpublic_v4 [
    {0x00000000, 8},
    {0x0A000000, 8},
    {0x64400000, 10},
    {0x7F000000, 8},
    {0xA9FE0000, 16},
    {0xAC100000, 12},
    {0xC0000000, 24},
    {0xC0000200, 24},
    {0xC0586300, 24},
    {0xC0A80000, 16},
    {0xC6120000, 15},
    {0xC6336400, 24},
    {0xCB007100, 24},
    {0xE0000000, 3}
  ]
  def resolve(url) do
    with {:ok, %URI{scheme: "https", host: host}} <- HTTP.validate_url(url),
         {:ok, addresses} <- bounded_addresses(host),
         true <- addresses != [] and Enum.all?(addresses, &public?/1) do
      {:ok, hd(addresses)}
    else
      _ -> {:error, :untrusted_destination}
    end
  end

  defp bounded_addresses(host) do
    task = Task.Supervisor.async_nolink(Arbor.A2A.Executor, fn -> addresses(host) end)

    case Task.yield(task, 2000) || Task.shutdown(task, :brutal_kill) do
      {:ok, {:ok, addresses}} -> {:ok, addresses}
      _ -> {:error, :dns_timeout}
    end
  rescue
    _ -> {:error, :dns_unavailable}
  end

  defp addresses(host) do
    addresses =
      for family <- [:inet, :inet6],
          {:ok, values} <- [:inet.getaddrs(String.to_charlist(host), family)],
          value <- values,
          do: value

    {:ok, Enum.uniq(addresses)}
  end

  def public?({a, b, c, d}) do
    value = :binary.decode_unsigned(<<a, b, c, d>>)

    not Enum.any?(@nonpublic_v4, fn {network, prefix} ->
      value >>> (32 - prefix) == network >>> (32 - prefix)
    end)
  end

  def public?({a, b, _, _, _, _, _, _}),
    do: a in 0x2000..0x3FFF and not (a == 0x2001 and b in [0, 2, 0xDB8]) and a != 0x2002

  def public?(_), do: false
end
