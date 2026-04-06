defmodule GrpcCase do
  use ExUnit.CaseTemplate

  using(service: service) do
    quote do
      import GrpcCase

      setup_all do
        Protobuf.load_extensions()
      end

      defmodule V1Server do
        use GrpcReflection.Server, version: :v1, services: [unquote(service)]
      end

      defmodule V1Server.Stub do
        use GRPC.Stub, service: Grpc.Reflection.V1.ServerReflection.Service
      end

      defmodule V1AlphaServer do
        use GrpcReflection.Server, version: :v1alpha, services: [unquote(service)]
      end

      defmodule V1AlphaServer.Stub do
        use GRPC.Stub, service: Grpc.Reflection.V1alpha.ServerReflection.Service
      end

      defmodule Endpoint do
        use GRPC.Endpoint

        run(V1Server)
        run(V1AlphaServer)
      end

      defp stub_v1_server(_) do
        # %{endpoint: Endpoint, stub: V1Server.Stub}

        {:ok, _pid, port} = GRPC.Server.start_endpoint(Endpoint, 0)
        on_exit(fn -> :ok = GRPC.Server.stop_endpoint(Endpoint, []) end)
        start_supervised({GRPC.Client.Supervisor, []})

        host = "localhost:#{port}"
        {:ok, channel} = GRPC.Stub.connect(host)

        req = %Grpc.Reflection.V1.ServerReflectionRequest{host: host}

        %{
          channel: channel,
          req: req,
          version: :v1,
          host: host,
          endpoint: Endpoint,
          stub: V1Server.Stub
        }
      end

      defp stub_v1alpha_server(_) do
        {:ok, _pid, port} = GRPC.Server.start_endpoint(Endpoint, 0)
        on_exit(fn -> :ok = GRPC.Server.stop_endpoint(Endpoint, []) end)
        start_supervised({GRPC.Client.Supervisor, []})

        host = "localhost:#{port}"
        {:ok, channel} = GRPC.Stub.connect(host)

        req = %Grpc.Reflection.V1alpha.ServerReflectionRequest{host: host}

        %{
          channel: channel,
          req: req,
          version: :v1alpha,
          host: host,
          endpoint: Endpoint,
          stub: V1AlphaServer.Stub
        }
      end
    end
  end

  alias Google.Protobuf.FileDescriptorProto

  setup do
    {:ok, _} = start_supervised(GrpcReflection)
    :ok
  end

  def run_request(message_request, ctx) do
    stream = ctx.stub.server_reflection_info(ctx.channel)
    request = %{ctx.req | message_request: message_request}
    GRPC.Stub.send_request(stream, request, end_stream: true)
    assert {:ok, reply_stream} = GRPC.Stub.recv(stream)
    assert [server_response] = Enum.to_list(reply_stream)
    assert {:ok, response} = server_response
    assert %{original_request: ^request} = response
    assert %{message_response: msg_response} = response

    case msg_response do
      {:file_descriptor_response, %{file_descriptor_proto: [encoded_proto]}} ->
        {:ok, FileDescriptorProto.decode(encoded_proto)}

      {:list_services_response, services} ->
        {:ok, services}

      {:all_extension_numbers_response, response} ->
        {:ok, response}

      {:error_response, resp} ->
        {:error, resp}
    end
  end
end
