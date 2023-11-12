defmodule Helloworld.ReflectionTest do
  @moduledoc """
  testing that reflection is on and we are exposing our types
  """

  use ExUnit.Case

  setup_all do
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    req = %Grpc.Reflection.V1.ServerReflectionRequest{host: "localhost:50051"}
    %{channel: channel, req: req}
  end

  test "listing services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    names = Enum.map(service_list, &Map.get(&1, :name))
    assert names == ["helloworld.Greeter", "grpc.reflection.v1.ServerReflection"]
  end

  test "listing methods on our service", ctx do
    message = {:file_containing_symbol, "helloworld.Greeter"}
    assert {:ok, response} = run_request(message, ctx)
    assert_response(response)
  end

  test "describing a method returns the service", ctx do
    message = {:file_containing_symbol, "helloworld.Greeter.SayHello"}
    assert {:ok, response} = run_request(message, ctx)
    assert_response(response)
  end

  test "describing an invalid method returns not found", ctx do
    message = {:file_containing_symbol, "helloworld.Greeter.SayHellp"}
    assert {:ok, response} = run_request(message, ctx)
    assert_response(response)

    # SayHellp is not a method on the service
    refute true
  end

  test "describing a type returns the type", ctx do
    message = {:file_containing_symbol, "helloworld.HelloRequest"}
    assert {:ok, response} = run_request(message, ctx)
    assert_response(response)
  end

  defp assert_response(%{service: [service]} = proto) do
    assert service.name == "Greeter"
    assert %{method: [method]} = service
    assert method.name == "SayHello"
    assert method.input_type == ".helloworld.HelloRequest"
    assert method.output_type == ".helloworld.HelloReply"
  end

  defp assert_response(%{message_type: [%{name: "HelloRequest"} = type]}) do
    assert %{field: [field]} = type
    assert field.name == "name"
    assert field.type == :TYPE_STRING
  end

  %Google.Protobuf.FileDescriptorProto{
    name: "helloworld-helloworld.HelloRequest.proto",
    package: "helloworld",
    dependency: [],
    message_type: [
      %Google.Protobuf.DescriptorProto{
        name: "HelloRequest",
        field: [
          %Google.Protobuf.FieldDescriptorProto{
            name: "name",
            extendee: nil,
            number: 1,
            label: :LABEL_OPTIONAL,
            type: :TYPE_STRING,
            type_name: nil,
            default_value: nil,
            options: nil,
            oneof_index: nil,
            json_name: "name",
            proto3_optional: nil,
            __unknown_fields__: []
          }
        ],
        nested_type: [],
        enum_type: [],
        extension_range: [],
        extension: [],
        options: nil,
        oneof_decl: [],
        reserved_range: [],
        reserved_name: [],
        __unknown_fields__: []
      }
    ],
    enum_type: [],
    service: [],
    extension: [],
    options: nil,
    source_code_info: nil,
    public_dependency: [],
    weak_dependency: [],
    syntax: nil,
    edition: nil,
    __unknown_fields__: []
  }

  defp run_request(message_request, ctx) do
    stream = Grpc.Reflection.V1.ServerReflection.Stub.server_reflection_info(ctx.channel)
    request = %{ctx.req | message_request: message_request}
    GRPC.Stub.send_request(stream, request, end_stream: true)
    assert {:ok, reply_stream} = GRPC.Stub.recv(stream)
    assert [server_response] = Enum.to_list(reply_stream)
    assert {:ok, response} = server_response
    assert %{original_request: ^request} = response
    assert %{message_response: msg_response} = response

    case msg_response do
      {:file_descriptor_response, %{file_descriptor_proto: [encoded_proto]}} ->
        {:ok, Google.Protobuf.FileDescriptorProto.decode(encoded_proto)}

      {:list_services_response, services} ->
        {:ok, services}
    end
  end
end
