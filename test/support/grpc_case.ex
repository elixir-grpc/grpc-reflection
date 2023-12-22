defmodule GrpcCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import GrpcCase
    end
  end

  alias Google.Protobuf.FileDescriptorProto

  setup do
    {:ok, _} = start_supervised(GrpcReflection)
    :ok
  end

  def assert_response(%{service: [service]}) do
    assert service.name == "Greeter"
    assert %{method: [method]} = service
    assert method.name == "SayHello"
    assert method.input_type == ".helloworld.HelloRequest"
    assert method.output_type == ".helloworld.HelloReply"
  end

  def assert_response(%{message_type: [%{name: "HelloRequest"} = type]}) do
    assert %{field: [field]} = type
    assert field.name == "name"
    assert field.type == :TYPE_STRING
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
