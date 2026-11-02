defmodule Arbor.A2A.TransportSafetyTest do
  use ExUnit.Case, async: true
  import Plug.Conn
  import Arbor.A2A.TestSupport
  alias Arbor.A2A.{Client, Error, HTTP, HttpPlug, Message, Server}

  defp listen(plug) do
    pid = start_supervised!({Bandit, plug: plug, ip: {127, 0, 0, 1}, port: 0, startup_log: false})
    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    "http://127.0.0.1:#{port}"
  end

  test "real auth boundary partitions caller tasks over HTTP" do
    {server, _store} = server()

    auth = fn conn ->
      case get_req_header(conn, "authorization") do
        ["Bearer alice"] -> {:ok, :alice}
        ["Bearer bob"] -> {:ok, :bob}
        _ -> {:error, :unauthorized}
      end
    end

    base =
      listen(fn conn, _ ->
        HttpPlug.call(conn, HttpPlug.init(server: server, authenticate: auth))
      end)

    {:ok, alice} = Client.new(base <> "/a2a", token_provider: fn -> {:ok, "alice"} end)
    {:ok, bob} = Client.new(base <> "/a2a", token_provider: fn -> {:ok, "bob"} end)
    {:ok, anon} = Client.new(base <> "/a2a")
    assert {:ok, %{"task" => task}} = Client.send_message(alice, Message.text("private"))
    assert {:error, %Error{code: -32_001}} = Client.get_task(bob, task["id"])
    assert {:ok, %{"tasks" => []}} = Client.list_tasks(bob)
    assert {:error, {:http_status, 401}} = Client.get_task(anon, task["id"])
  end

  test "redirects are returned without forwarding a credential or retrying" do
    owner = self()

    base =
      listen(fn conn, _ ->
        send(owner, {:request, conn.request_path, get_req_header(conn, "authorization")})
        conn |> put_resp_header("location", "/credential-target") |> send_resp(302, "redirect")
      end)

    {:ok, client} = Client.new(base <> "/a2a", token_provider: fn -> {:ok, "fixture-secret"} end)
    assert {:error, {:http_status, 302}} = Client.list_tasks(client)
    assert_receive {:request, "/a2a", ["Bearer fixture-secret"]}
    refute_receive {:request, _, _}, 20
  end

  test "wrong IDs and ambiguous response envelopes are refused" do
    base =
      listen(fn conn, _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ~s({"jsonrpc":"2.0","id":"wrong","result":{}}))
      end)

    {:ok, client} = Client.new(base <> "/a2a")
    assert {:error, :invalid_response} = Client.list_tasks(client)
  end

  test "HTTP deadlines and response size bounds apply to actual sockets" do
    base =
      listen(fn conn, _ ->
        Process.sleep(100)
        conn |> put_resp_content_type("application/json") |> send_resp(200, "{}")
      end)

    assert {:error, :timeout} = HTTP.request("GET", base, [], nil, timeout: 10)
    assert {:error, :invalid_http_options} = HTTP.request("GET", base, [], nil, timeout: 0)

    assert {:error, :invalid_http_options} =
             HTTP.request("GET", base, [], nil, max_response_bytes: -1)
  end

  test "a disappearing caller cannot leave a callback running forever" do
    {server, _store} = server(timeout: 25)
    server = %{server | handler: Arbor.A2A.WatchedAgent}
    owner = self()

    caller =
      spawn(fn ->
        Server.dispatch(server, "SendMessage", Map.put(params("timeout"), "observer", owner))
      end)

    assert_receive {:callback_worker, worker}
    monitor = Process.monitor(worker)
    Process.exit(caller, :kill)
    assert_receive {:DOWN, ^monitor, :process, ^worker, _}, 1000
  end
end

defmodule Arbor.A2A.WatchedAgent do
  @moduledoc false
  @behaviour Arbor.A2A.Server.Handler
  @impl true
  def handle_message(params, _context) do
    send(params["observer"], {:callback_worker, self()})
    Process.sleep(:infinity)
  end
end
