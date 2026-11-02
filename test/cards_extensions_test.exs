defmodule Arbor.A2A.CardsExtensionsTest do
  use ExUnit.Case, async: true
  import Arbor.A2A.TestSupport
  import Plug.Conn
  import Plug.Test
  alias Arbor.A2A.{CardSignature, HttpPlug, Protocol, RestPlug, Server}

  test "signatures use canonical JSON and caller-bound trust" do
    key = JOSE.JWK.generate_key({:rsa, 2048})
    {:ok, signed} = CardSignature.sign(card(), key, "RS256", kid: "test")
    assert :ok = CardSignature.verify(signed, JOSE.JWK.to_public(key), ["RS256"], kid: "test")

    assert {:error, _} =
             CardSignature.verify(Map.put(signed, "description", "tampered"), key, ["RS256"])

    assert {:error, _} = CardSignature.verify(signed, key, ["ES256"])
    assert {:error, _} = CardSignature.sign(card(), key, "none")
    assert {:ok, one} = CardSignature.canonicalize(card())

    assert {:ok, other} =
             CardSignature.canonicalize(put_in(card(), ["capabilities", "streaming"], false))

    assert one != other
    assert other =~ ~s("streaming":false)
  end

  test "required extension negotiation rejects missing support and acknowledges supported versions" do
    {server, _} = server()
    extension = %{"uri" => "https://example.com/ext/v1", "required" => true}
    server = %{server | card: put_in(server.card, ["capabilities", "extensions"], [extension])}
    opts = HttpPlug.init(server: server)

    req =
      conn(:post, "/a2a", Jason.encode!(Protocol.request("ListTasks", %{}, 1)))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("a2a-version", "1.0")

    missing = HttpPlug.call(req, opts)
    assert Jason.decode!(missing.resp_body)["error"]["code"] == -32_008
    present = req |> put_req_header("a2a-extensions", extension["uri"]) |> HttpPlug.call(opts)
    assert get_resp_header(present, "a2a-extensions") == [extension["uri"]]
    assert Jason.decode!(present.resp_body)["result"]["tasks"] == []
  end

  test "extended cards require an authenticated principal and distinct configuration" do
    {server, _} = server()
    public = put_in(server.card, ["capabilities", "extendedAgentCard"], true)

    {:ok, configured} =
      Server.new(
        handler: server.handler,
        store: server.store,
        card: public,
        extended_card: Map.put(public, "description", "private")
      )

    assert {:error, _} = Server.dispatch(configured, "GetExtendedAgentCard", %{})

    assert {:ok, %{"description" => "private"}} =
             Server.dispatch(configured, "GetExtendedAgentCard", %{}, :alice)
  end

  test "authenticated REST extended cards and RPC operations prohibit caching" do
    {server, _} = server()
    public = put_in(server.card, ["capabilities", "extendedAgentCard"], true)

    {:ok, configured} =
      Server.new(
        handler: server.handler,
        store: server.store,
        card: public,
        extended_card: Map.put(public, "description", "private")
      )

    opts =
      RestPlug.init(server: configured, path: "/rest", authenticate: fn _ -> {:ok, :alice} end)

    response =
      conn(:get, "/rest/extendedAgentCard")
      |> put_req_header("a2a-version", "1.0")
      |> RestPlug.call(opts)

    assert response.status == 200
    assert get_resp_header(response, "cache-control") == ["no-store"]
    opts = HttpPlug.init(server: server)

    response =
      conn(:post, "/a2a", Jason.encode!(Protocol.request("ListTasks", %{}, 1)))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("a2a-version", "1.0")
      |> HttpPlug.call(opts)

    assert get_resp_header(response, "cache-control") == ["no-store"]
  end
end
