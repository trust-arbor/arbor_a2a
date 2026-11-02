if Code.ensure_loaded?(GRPC.Server) do
  defmodule Arbor.A2A.GRPCServer do
    @moduledoc """
    gRPC binding macro. Define a host module with
    `use Arbor.A2A.GRPCServer, server: MyHost.server(), authenticate: &MyHost.authenticate/1`
    and supervise it through `GRPC.Server.Supervisor`. Authentication receives
    request metadata and returns the same principal tuple as the HTTP callback.
    Configure TLS in the gRPC listener; cleartext is suitable only for local tests.
    The host expression is evaluated per call, allowing independently supervised
    instances without application-global server state.
    """
    alias Arbor.A2A.{Error, Extensions, ProtoJSON, RestPlug, Schema, Server}
    alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire

    alias Google.Protobuf.Any
    alias Google.Rpc.ErrorInfo
    alias Wire.A2AService.Service

    defmacro __using__(opts) do
      server = Keyword.fetch!(opts, :server)
      authenticate = Keyword.get(opts, :authenticate)
      methods = Service.__rpc_calls__()

      definitions =
        for {name, _, _, _} <- methods do
          function = name |> Atom.to_string() |> Macro.underscore() |> String.to_atom()

          quote do
            def unquote(function)(request, stream) do
              unquote(__MODULE__).dispatch(
                unquote(server),
                unquote(Atom.to_string(name)),
                request,
                stream,
                unquote(authenticate)
              )
            end
          end
        end

      quote do
        use GRPC.Server, service: unquote(Service)
        unquote_splicing(definitions)
      end
    end

    @doc false
    def dispatch(server, method, request, stream, authenticate) do
      metadata = stream.http_request_headers

      with {:ok, principal} <- authenticate(server, metadata, authenticate),
           :ok <- version(metadata),
           {:ok, active} <- extensions(server, metadata),
           {:ok, params} <- Protobuf.JSON.to_encodable(request) do
        dispatch_method(server, method, params, principal, stream, active)
      else
        {:error, %Error{} = error} -> raise_error(error)
        {:error, :forbidden} -> raise GRPC.RPCError, status: :permission_denied
        _ -> raise GRPC.RPCError, status: :unauthenticated
      end
    end

    defp dispatch_method(server, method, params, principal, stream, active)
         when method in ~w(SendStreamingMessage SubscribeToTask) do
      case Server.stream(server, method, params, principal, extensions: active) do
        {:ok, events} ->
          _stream = Enum.reduce(events, stream, &send_event/2)
          nil

        {:error, error} ->
          raise_error(error)
      end
    end

    defp dispatch_method(server, method, params, principal, _, active) do
      case Server.dispatch(server, method, params, principal, extensions: active) do
        {:ok, value} -> to_proto(value, Schema.response_type(method))
        {:error, error} -> raise_error(error)
      end
    end

    defp send_event(:heartbeat, stream), do: stream
    defp send_event({:error, %Error{} = error}, _), do: raise_error(error)
    defp send_event({:error, _}, _), do: raise_error(Error.new(:internal_error))

    defp send_event(event, stream),
      do: GRPC.Server.send_reply(stream, to_proto(event, Wire.StreamResponse))

    defp authenticate(server, _, nil) do
      if Map.get(server.card, "securityRequirements", []) == [],
        do: {:ok, :anonymous},
        else: {:error, :unauthorized}
    end

    defp authenticate(_, metadata, callback) do
      case callback.(metadata) do
        {:ok, principal} when not is_nil(principal) -> {:ok, principal}
        {:error, :forbidden} -> {:error, :forbidden}
        _ -> {:error, :unauthorized}
      end
    rescue
      _ -> {:error, :unauthorized}
    end

    defp version(metadata) do
      if Regex.match?(~r/^1\.0(?:\.\d+)?$/, Map.get(metadata, "a2a-version", "")),
        do: :ok,
        else: {:error, Error.new(:version_not_supported)}
    end

    defp extensions(server, metadata) do
      requested =
        Map.get(metadata, "a2a-extensions", "") |> String.split(",") |> Enum.map(&String.trim/1)

      Extensions.negotiate(server.card, requested)
    end

    defp to_proto(map, module), do: ProtoJSON.decode!(map, module)

    defp raise_error(error) do
      {_, name} = RestPlug.http_error(error)
      status = name |> String.downcase() |> String.to_existing_atom()

      details =
        Enum.map(error.data || [], fn detail ->
          info = %ErrorInfo{
            reason: detail["reason"],
            domain: detail["domain"],
            metadata: %{}
          }

          %Any{
            type_url: "type.googleapis.com/google.rpc.ErrorInfo",
            value: ErrorInfo.encode(info)
          }
        end)

      raise GRPC.RPCError, status: status, message: error.message, details: details
    end
  end
end
