defmodule Arbor.A2A.HTTPTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn
  import Arbor.A2A.TestSupport
  alias Arbor.A2A.{Client, Error, HttpPlug, Message}

  setup do
    {server, _store} = server()
    opts = HttpPlug.init(server: server)
    %{server: server, opts: opts}
  end

  defp request(body, opts, headers \\ []) do
    conn(:post, "/a2a", body)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("a2a-version", "1.0")
    |> then(fn c ->
      Enum.reduce(headers, c, fn {k, v}, conn -> put_req_header(conn, k, v) end)
    end)
    |> HttpPlug.call(opts)
  end

  defp rpc(method, params \\ %{}),
    do: Jason.encode!(%{"jsonrpc" => "2.0", "id" => 10, "method" => method, "params" => params})

  test "well-known card is public and cacheable", %{opts: opts} do
    conn = HttpPlug.call(conn(:get, "/.well-known/agent-card.json"), opts)
    assert conn.status == 200
    assert get_resp_header(conn, "cache-control") == ["public, max-age=60"]
    assert Jason.decode!(conn.resp_body)["name"] == "Echo"
  end

  test "HTTP methods and media types are rejected before dispatch", %{opts: opts} do
    assert HttpPlug.call(conn(:get, "/a2a"), opts).status == 405
    assert HttpPlug.call(conn(:get, "/missing"), opts).status == 404
    assert HttpPlug.call(conn(:post, "/a2a", "x"), opts).status == 415

    assert HttpPlug.call(
             conn(:post, "/a2a", "x") |> put_req_header("content-type", "text/plain"),
             opts
           ).status == 415
  end

  for version <- ~w(1.1 0.3 garbage 2.0) do
    test "unsupported version #{version} returns A2A error", %{opts: opts} do
      conn = request(rpc("ListTasks"), opts, [{"a2a-version", unquote(version)}])
      assert Jason.decode!(conn.resp_body)["error"]["code"] == -32_009
    end
  end

  test "patch versions are ignored, missing version is treated as unsupported 0.3", %{opts: opts} do
    assert Jason.decode!(request(rpc("ListTasks"), opts, [{"a2a-version", "1.0.99"}]).resp_body)[
             "result"
           ]

    conn =
      conn(:post, "/a2a", rpc("ListTasks"))
      |> put_req_header("content-type", "application/json")
      |> HttpPlug.call(opts)

    assert Jason.decode!(conn.resp_body)["error"]["code"] == -32_009
  end

  test "body limits and parse errors have controlled responses", %{opts: opts} do
    assert request(String.duplicate("x", 64), Keyword.put(opts, :max_body_bytes, 10)).status ==
             413

    assert Jason.decode!(request("{", opts).resp_body)["error"]["code"] == -32_700
  end

  test "auth fails closed before body parsing and does not expose callback errors", %{
    server: server
  } do
    for auth <- [
          fn _ -> {:error, :unauthorized} end,
          fn _ -> raise "secret" end,
          fn _ -> throw("secret") end
        ] do
      opts = HttpPlug.init(server: server, authenticate: auth)
      conn = request("invalid JSON", opts)
      assert conn.status == 401
      refute conn.resp_body =~ "secret"
      assert get_resp_header(conn, "www-authenticate") == ["Bearer"]
    end

    assert request(
             "{",
             HttpPlug.init(server: server, authenticate: fn _ -> {:error, :forbidden} end)
           ).status == 403
  end

  test "declared security requires an actual authentication callback", %{server: server} do
    server = %{
      server
      | card:
          Map.put(server.card, "securityRequirements", [
            %{"schemes" => %{"oauth" => %{"scopes" => []}}}
          ])
    }

    assert_raise ArgumentError, fn -> HttpPlug.init(server: server) end
  end

  test "client URL and header validation rejects credential redirection" do
    assert {:error, :https_required} = Client.new("http://remote.example/a2a")
    assert {:error, :invalid_url} = Client.new("https://user:pass@example.com/a2a")

    assert {:error, :invalid_client_options} =
             Client.new("https://example.com/a2a", headers: [{"Authorization", "secret"}])

    assert {:error, :invalid_client_options} =
             Client.new("https://example.com/a2a", headers: [{"x-key", "bad\r\n"}])
  end

  test "live Bandit server and Mint client round-trip tasks and errors", %{server: server} do
    plug = fn conn, _opts ->
      current = %{server | card: card("http://127.0.0.1:#{conn.port}/a2a")}
      HttpPlug.call(conn, HttpPlug.init(server: current))
    end

    pid =
      start_supervised!({Bandit, plug: plug, ip: {127, 0, 0, 1}, port: 0, startup_log: false})

    {:ok, {_address, port}} = ThousandIsland.listener_info(pid)
    url = "http://127.0.0.1:#{port}/a2a"
    {:ok, client} = Client.new(url)
    assert {:ok, %{"task" => task}} = Client.send_message(client, Message.text("hello"))
    assert {:ok, ^task} = Client.get_task(client, task["id"])
    assert {:ok, %{"tasks" => [_]}} = Client.list_tasks(client)
    assert {:error, %Error{code: -32_001}} = Client.get_task(client, "missing")
    assert {:ok, card} = Client.discover(url)
    assert card["name"] == "Echo"
    assert {:error, :response_too_large} = Client.list_tasks(%{client | max_response_bytes: 1})
  end

  test "token providers fail locally and are redacted in Inspect" do
    {:ok, client} =
      Client.new("https://example.invalid/a2a", token_provider: fn -> {:error, "secret"} end)

    assert {:error, :token_unavailable} = Client.list_tasks(client)
    refute inspect(client) =~ "secret"

    assert {:error, :token_unavailable} =
             Client.list_tasks(%{client | token_provider: fn -> {:ok, "bad\r\ntoken"} end})
  end
end
