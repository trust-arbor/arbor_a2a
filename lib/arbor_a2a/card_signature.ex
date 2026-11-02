if Code.ensure_loaded?(JOSE.JWS) do
  defmodule Arbor.A2A.CardSignature do
    @moduledoc """
    Detached Agent Card JWS with RFC 8785 canonicalization and ProtoJSON field
    presence semantics. Keys and permitted algorithms must come from host trust
    configuration. No key/URL supplied by a card or JWS header is fetched or trusted.
    Requires optional JOSE. Supports RS256, ES256 and EdDSA; never `none` or a
    symmetric signing algorithm for public cards.
    """
    alias Arbor.A2A.{AgentCard, Schema}
    @algorithms ~w(RS256 ES256 EdDSA)
    def sign(card, key, algorithm, opts \\ [])

    def sign(card, key, algorithm, opts) when algorithm in @algorithms do
      with :ok <- AgentCard.validate(card),
           {:ok, payload} <- canonicalize(card) do
        header =
          Map.merge(
            %{"alg" => algorithm},
            Map.new(Keyword.take(opts, [:kid]), fn {k, v} -> {Atom.to_string(k), v} end)
          )

        {_, signed} = JOSE.JWS.sign(key, payload, header)
        signature = Map.take(signed, ["protected", "signature"])
        {:ok, Map.update(card, "signatures", [signature], &(&1 ++ [signature]))}
      end
    rescue
      _ -> {:error, :card_signing_failed}
    end

    def sign(_, _, _, _), do: {:error, :unsupported_signature_algorithm}

    def verify(card, key, algorithms, opts \\ []) do
      with true <- algorithms != [] and Enum.all?(algorithms, &(&1 in @algorithms)),
           :ok <- AgentCard.validate(card),
           {:ok, payload} <- canonicalize(card),
           true <-
             Enum.any?(
               Map.get(card, "signatures", []),
               &valid_signature?(&1, payload, key, algorithms, opts)
             ) do
        :ok
      else
        _ -> {:error, :invalid_card_signature}
      end
    rescue
      _ -> {:error, :invalid_card_signature}
    end

    def canonicalize(card) do
      with {:ok, card} <-
             Schema.normalize(Arbor.A2A.Proto.Lf.A2a.V1.AgentCard, Map.delete(card, "signatures")),
           {:ok, proto} <-
             Protobuf.JSON.decode(Jason.encode!(card), Arbor.A2A.Proto.Lf.A2a.V1.AgentCard),
           {:ok, value} <- Protobuf.JSON.to_encodable(proto) do
        {:ok, Jcs.encode(value)}
      end
    rescue
      _ -> {:error, :invalid_agent_card}
    end

    defp valid_signature?(signature, payload, key, algorithms, opts) do
      with {:ok, header_bytes} <- Base.url_decode64(signature["protected"], padding: false),
           {:ok, header} <- Jason.decode(header_bytes),
           true <- not Map.has_key?(header, "crit") and not Map.has_key?(header, "b64"),
           true <- is_nil(opts[:kid]) or header["kid"] == opts[:kid],
           {true, ^payload, _} <-
             JOSE.JWS.verify_strict(
               key,
               algorithms,
               Map.put(signature, "payload", Base.url_encode64(payload, padding: false))
             ) do
        true
      else
        _ -> false
      end
    rescue
      _ -> false
    end
  end
end
