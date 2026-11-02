defmodule Arbor.A2A.SecurityOptionsTest do
  use ExUnit.Case, async: true

  alias Arbor.A2A.{
    Client,
    HTTP,
    HttpPlug,
    Message,
    RestPlug,
    Security,
    Task,
    TaskStore,
    TestSupport
  }

  test "security alternatives require every scheme in the chosen conjunction" do
    card = %{
      "securitySchemes" => %{"oauth" => %{}, "key" => %{}},
      "securityRequirements" => [
        %{"schemes" => %{"oauth" => %{"list" => ["read"]}, "key" => %{}}}
      ]
    }

    assert {:error, _} = Security.select(card, ["oauth"])

    assert {:ok, %{"oauth" => %{scopes: ["read"]}, "key" => _}} =
             Security.select(card, ["oauth", "key"])
  end

  test "HTTP auth is per call, exclusive, redacted and rejects header injection" do
    owner = self()

    pid =
      start_supervised!(
        {Bandit,
         plug: fn conn, _ ->
           send(owner, {:auth, Plug.Conn.get_req_header(conn, "authorization")})
           Plug.Conn.send_resp(conn, 401, "Unauthorized")
         end,
         port: 0,
         ip: {127, 0, 0, 1}}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    url = "http://127.0.0.1:#{port}"
    {:ok, client} = Client.new(url, http_auth: fn -> {:ok, "Basic", "fixture"} end)
    assert {:error, {:http_status, 401}} = Client.list_tasks(client)
    assert_receive {:auth, ["Basic fixture"]}
    refute inspect(client) =~ "http_auth"

    assert {:error, _} =
             Client.new(url, http_auth: fn -> :error end, token_provider: fn -> :error end)

    {:ok, invalid} = Client.new(url, http_auth: fn -> {:ok, "Bearer", "x\r\ny: z"} end)
    assert {:error, :token_unavailable} = Client.list_tasks(invalid)
  end

  test "REST client uses canonical calls and stream errors remain typed" do
    {server, _} = TestSupport.server()
    rest = RestPlug.init(server: server, path: "/rest")
    rpc = HttpPlug.init(server: server)

    pid =
      start_supervised!(
        {Bandit,
         plug: fn conn, _ ->
           if String.starts_with?(conn.request_path, "/rest"),
             do: RestPlug.call(conn, rest),
             else: HttpPlug.call(conn, rpc)
         end,
         port: 0,
         ip: {127, 0, 0, 1}}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    {:ok, client} = Client.new("http://127.0.0.1:#{port}/rest", binding: :rest)
    assert {:ok, %{"task" => task}} = Client.send_message(client, Message.text("hello"))
    assert {:ok, %{"id" => id}} = Client.get_task(client, task["id"])
    assert id == task["id"]
    {:ok, stream} = Client.new("http://127.0.0.1:#{port}/a2a")

    assert {:error, %Arbor.A2A.Error{code: -32_004}} =
             Client.stream(
               stream,
               "SendStreamingMessage",
               %{"message" => Message.text("x")},
               nil,
               fn _, acc -> {:cont, acc} end
             )
  end

  test "task leases reject concurrent and stale executions" do
    {:ok, store} = TaskStore.start_link()
    task = Task.new("ctx")
    :ok = TaskStore.put(store, :alice, task)
    {:ok, lease} = TaskStore.claim(store, :alice, task["id"], task)
    assert {:error, _} = TaskStore.claim(store, :alice, task["id"], task)
    :ok = TaskStore.release(store, lease)
    changed = Map.put(task, "metadata", %{"changed" => true})
    :ok = TaskStore.put(store, :alice, changed)
    assert {:error, _} = TaskStore.claim(store, :alice, task["id"], task)
    assert {:ok, _} = TaskStore.claim(store, :alice, task["id"], changed)
  end

  test "HTTP option validation cannot disable TLS verification" do
    assert {:error, :invalid_tls_options} = HTTP.tls_options(tls_options: [verify: :verify_none])
  end

  test "task-store diagnostic status does not expose task data or cursor secrets" do
    {:ok, store} = TaskStore.start_link()
    task = Map.put(Task.new("ctx"), "metadata", %{"private" => "private-fixture-sentinel"})
    :ok = TaskStore.put(store, :alice, task)
    status = inspect(:sys.get_status(store), limit: :infinity)
    refute status =~ "private-fixture-sentinel"
    assert status =~ "redacted_task_store"
  end
end
