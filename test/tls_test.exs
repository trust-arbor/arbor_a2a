defmodule Arbor.A2A.TLSTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Client, HTTP}

  test "TLS verifies server identity and supports a required client certificate" do
    key = [key: {:namedCurve, :secp256r1}, digest: :sha256]
    san = {:Extension, {2, 5, 29, 17}, false, [dNSName: ~c"localhost"]}

    %{server_config: server, client_config: client} =
      :public_key.pkix_test_data(%{
        server_chain: %{root: key, intermediates: [], peer: key ++ [extensions: [san]]},
        client_chain: %{root: key, intermediates: [], peer: key}
      })

    owner = self()
    pid = spawn(fn -> serve(server, owner) end)
    on_exit(fn -> Process.exit(pid, :kill) end)
    assert_receive {:tls_ready, port}, 5000
    url = "https://localhost:#{port}/"
    trusted = Keyword.take(client, [:cert, :key, :cacerts])
    opts = [connect_address: {127, 0, 0, 1}, tls_options: trusted]
    assert {:ok, %{status: 200}} = HTTP.request("GET", url, [], nil, opts)

    assert {:error, _} =
             HTTP.request(
               "GET",
               url,
               [],
               nil,
               Keyword.put(opts, :tls_options, Keyword.take(client, [:cacerts]))
             )

    assert {:error, _} = HTTP.request("GET", url, [], nil, connect_address: {127, 0, 0, 1})
    assert {:error, :invalid_tls_options} = Client.new(url, tls_options: [verify: :verify_none])
  end

  defp serve(config, owner) do
    opts =
      [:binary] ++
        Keyword.merge(config,
          active: false,
          ip: {127, 0, 0, 1},
          reuseaddr: true,
          verify: :verify_peer,
          fail_if_no_peer_cert: true
        )

    {:ok, listener} = :ssl.listen(0, opts)
    {:ok, {_, port}} = :ssl.sockname(listener)
    send(owner, {:tls_ready, port})

    for _ <- 1..3 do
      {:ok, transport} = :ssl.transport_accept(listener, 5000)
      respond(transport)
    end

    :ssl.close(listener)
  end

  defp respond(transport) do
    case :ssl.handshake(transport, 5000) do
      {:ok, socket} ->
        {:ok, _} = :ssl.recv(socket, 0, 5000)

        :ssl.send(
          socket,
          "HTTP/1.1 200 OK\r\ncontent-type: application/json\r\ncontent-length: 2\r\nconnection: close\r\n\r\n{}"
        )

        :ssl.close(socket)

      _ ->
        :ok
    end
  end
end
