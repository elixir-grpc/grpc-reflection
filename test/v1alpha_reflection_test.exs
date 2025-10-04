defmodule GrpcReflection.V1alphaReflectionTest do
  @moduledoc false

  use GrpcCase
  alias GrpcReflection.Service.Builder.Util

  @moduletag capture_log: true

  setup_all do
    Protobuf.load_extensions()
    endpoint = GrpcReflection.TestEndpoint.Endpoint
    {:ok, _pid, port} = GRPC.Server.start_endpoint(endpoint, 0)
    host = "localhost:#{port}"
    {:ok, channel} = GRPC.Stub.connect(host)
    req = %Grpc.Reflection.V1alpha.ServerReflectionRequest{host: host}

    on_exit(fn ->
      :ok = GRPC.Server.stop_endpoint(endpoint, [])
    end)

    %{channel: channel, req: req, stub: GrpcReflection.TestEndpoint.V1AlphaServer.Stub}
  end

  test "unsupported call is rejected", ctx do
    message = {:file_containing_extension, %Grpc.Reflection.V1alpha.ExtensionRequest{}}
    assert {:error, _} = run_request(message, ctx)
  end

  describe "listing services" do
    test "listing services", ctx do
      message = {:list_services, ""}
      assert {:ok, %{service: service_list}} = run_request(message, ctx)
      names = Enum.map(service_list, &Map.get(&1, :name))

      assert names == [
               "helloworld.Greeter",
               "testserviceV2.TestService",
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

    test "describing a root type returns the type", ctx do
      message = {:file_containing_symbol, "helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "describing a nested type returns the root type", ctx do
      message = {:file_containing_symbol, "testserviceV3.TestRequest.Payload"}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == "test_service_v3.proto"
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

      assert [%{name: "Greeter", method: methods}] = response.service
      assert Enum.map(methods, & &1.name) == ["SayHello"]
    end

    test "reject filename that doesn't match a reflection module", ctx do
      filename = "does.not.exist.proto"
      message = {:file_by_filename, filename}
      assert {:error, _} = run_request(message, ctx)
    end

    test "get replytype by filename", ctx do
      filename = "helloworld.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "helloworld"
      assert response.dependency == ["google/protobuf/timestamp.proto"]

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
      filename = "google/protobuf/timestamp.proto"
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
      filename = "test_service_v3.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"

      assert Enum.sort(response.dependency) ==
               Enum.sort([
                 "google/protobuf/timestamp.proto",
                 "google/protobuf/wrappers.proto",
                 "google/protobuf/any.proto"
               ])
    end

    test "ensure exclusion of nested types in file descriptor dependencies", ctx do
      filename = "test_service_v3.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"

      assert Enum.sort(response.dependency) ==
               Enum.sort([
                 "google/protobuf/any.proto",
                 "google/protobuf/timestamp.proto",
                 "google/protobuf/wrappers.proto"
               ])
    end
  end

  describe "proto2 extensions" do
    test "get all extension numbers by type", ctx do
      type = "testserviceV2.TestRequest"
      message = {:all_extension_numbers_of_type, type}
      assert {:ok, response} = run_request(message, ctx)
      assert response.base_type_name == type
      assert response.extension_number == [10, 11]
    end

    test "get extension descriptor file by extendee", ctx do
      extendee = "testserviceV2.TestRequest"

      message =
        {:file_containing_extension,
         %Grpc.Reflection.V1alpha.ExtensionRequest{
           containing_type: extendee,
           extension_number: 10
         }}

      assert {:ok, response} = run_request(message, ctx)
      assert response.name == extendee <> "Extension.proto"
      assert response.package == "testserviceV2"
      assert response.dependency == [Util.proto_filename(TestserviceV2.TestRequest)]

      assert response.extension == [
               %Google.Protobuf.FieldDescriptorProto{
                 name: "data",
                 extendee: extendee,
                 number: 10,
                 label: :LABEL_OPTIONAL,
                 type: :TYPE_STRING,
                 type_name: nil
               },
               %Google.Protobuf.FieldDescriptorProto{
                 name: "location",
                 extendee: extendee,
                 number: 11,
                 label: :LABEL_OPTIONAL,
                 type: :TYPE_MESSAGE,
                 type_name: "testserviceV2.Location"
               }
             ]

      assert response.message_type == [
               %Google.Protobuf.DescriptorProto{
                 name: "Location",
                 field: [
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "latitude",
                     number: 1,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_DOUBLE,
                     json_name: "latitude"
                   },
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "longitude",
                     extendee: nil,
                     number: 2,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_DOUBLE,
                     json_name: "longitude"
                   }
                 ]
               }
             ]
    end
  end
end
