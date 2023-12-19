defmodule GrpcReflection.V1ReflectionTest do
  @moduledoc false

  use GrpcCase

  @moduletag capture_log: true

  setup_all do
    endpoint = GrpcReflection.TestEndpoint.Endpoint
    {:ok, _pid, port} = GRPC.Server.start_endpoint(endpoint, 0)
    host = "localhost:#{port}"
    {:ok, channel} = GRPC.Stub.connect(host)
    req = %Grpc.Reflection.V1.ServerReflectionRequest{host: host}

    on_exit(fn ->
      :ok = GRPC.Server.stop_endpoint(endpoint, [])
    end)

    %{channel: channel, req: req, stub: GrpcReflection.TestEndpoint.V1Server.Stub}
  end

  test "unsupported call is rejected", ctx do
    message = {:file_containing_extension, %Grpc.Reflection.V1.ExtensionRequest{}}
    assert {:error, _} = run_request(message, ctx)
  end

  describe "listing services" do
    test "listing services", ctx do
      message = {:list_services, ""}
      assert {:ok, %{service: service_list}} = run_request(message, ctx)
      names = Enum.map(service_list, &Map.get(&1, :name))

      assert names == [
               "helloworld.Greeter",
               "testserviceV3.TestService",
               "grpc.reflection.v1.ServerReflection",
               "grpc.reflection.v1alpha.ServerReflection"
             ]
    end
  end

  describe "describe by symbol" do
    test "unknown symbol is rejected", ctx do
      message = {:file_containing_symbol, "other.Rejecter"}
      assert {:error, _} = run_request(message, ctx)
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
      # SayHellp is not a method on the service
      message = {:file_containing_symbol, "helloworld.Greeter.SayHellp"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "describing a type returns the type", ctx do
      message = {:file_containing_symbol, "helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "type with leading period still resolves", ctx do
      message = {:file_containing_symbol, ".helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end
  end

  describe "filename traversal" do
    test "listing methods on our service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)

      # we pretend all modules are in different files, dependencies are listed
      assert response.dependency == [
               "helloworld.HelloRequest.proto",
               "helloworld.HelloReply.proto"
             ]
    end

    test "reject filename that doesn't match a reflection module", ctx do
      filename = "does.not.exist.proto"
      message = {:file_by_filename, filename}
      assert {:error, _} = run_request(message, ctx)
    end

    test "get replytype by filename", ctx do
      filename = "helloworld.HelloReply.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "helloworld"
      assert response.dependency == ["google.protobuf.Timestamp.proto"]

      assert [
               %Google.Protobuf.DescriptorProto{
                 name: "HelloReply",
                 field: [
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "message",
                     number: 1,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_STRING,
                     json_name: "message"
                   },
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "today",
                     number: 2,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_MESSAGE,
                     type_name: ".google.protobuf.Timestamp",
                     json_name: "today"
                   }
                 ]
               }
             ] = response.message_type
    end

    test "get external by filename", ctx do
      filename = "google.protobuf.Timestamp.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "google.protobuf"
      assert response.dependency == []

      assert [
               %Google.Protobuf.DescriptorProto{
                 field: [
                   %Google.Protobuf.FieldDescriptorProto{
                     json_name: "seconds",
                     label: :LABEL_OPTIONAL,
                     name: "seconds",
                     number: 1,
                     type: :TYPE_INT64
                   },
                   %Google.Protobuf.FieldDescriptorProto{
                     json_name: "nanos",
                     label: :LABEL_OPTIONAL,
                     name: "nanos",
                     number: 2,
                     type: :TYPE_INT32
                   }
                 ],
                 name: "Timestamp"
               }
             ] = response.message_type
    end

    test "ensures file descriptor dependencies are unique", ctx do
      filename = "testserviceV3.TestReply.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"
      assert response.dependency ==  ["google.protobuf.Timestamp.proto", "google.protobuf.StringValue.proto"]
    end
  end
end
