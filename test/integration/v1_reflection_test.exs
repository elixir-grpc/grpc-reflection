defmodule GrpcReflection.V1ReflectionTest do
  @moduledoc false

  use GrpcCase
  use GrpcReflection.TestClient, version: :v1

  @moduletag capture_log: true

  test "unsupported call is rejected", ctx do
    message = {:file_containing_extension, %Grpc.Reflection.V1.ExtensionRequest{}}
    assert {:error, _} = run_request(message, ctx)
  end

  test "listing services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    names = Enum.map(service_list, &Map.get(&1, :name))

    assert names == [
             "helloworld.Greeter",
             "testserviceV2.TestService",
             "testserviceV3.TestService",
             "grpc.reflection.v1.ServerReflection",
             "grpc.reflection.v1alpha.ServerReflection",
             "recursive_message.Service"
           ]
  end

  describe "symbol queries" do
    test "ushould reject nknown symbol", ctx do
      message = {:file_containing_symbol, "other.Rejecter"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return a method on the service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter.SayHello"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return not found for an invalid method", ctx do
      # SayHellp is not a method on the service
      message = {:file_containing_symbol, "helloworld.Greeter.SayHellp"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should resolve a type", ctx do
      message = {:file_containing_symbol, "helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return the containing file for a nested message", ctx do
      message = {:file_containing_symbol, "testserviceV3.TestRequest.Payload"}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == "testserviceV3.TestRequest.proto"
    end

    test "should resolve types with the leading period", ctx do
      message = {:file_containing_symbol, ".helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end
  end

  describe "filename queries" do
    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)

      # we pretend all modules are in different files, dependencies are listed
      assert response.dependency == [
               "helloworld.HelloRequest.proto",
               "helloworld.HelloReply.proto"
             ]
    end

    test "should reject an unrecognized filename", ctx do
      filename = "does.not.exist.proto"
      message = {:file_by_filename, filename}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should resolve by filename", ctx do
      filename = "helloworld.HelloReply.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "helloworld"
      assert response.dependency == ["google.protobuf.Timestamp.proto"]

      assert [
               %Google.Protobuf.DescriptorProto{name: "HelloReply"}
             ] = response.message_type
    end

    test "should resolve external dependency types", ctx do
      filename = "google.protobuf.Timestamp.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "google.protobuf"
      assert response.dependency == []

      assert [
               %Google.Protobuf.DescriptorProto{name: "Timestamp"}
             ] = response.message_type
    end

    test "should not duplicate dependencies in the file descriptor", ctx do
      filename = "testserviceV3.TestReply.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"

      assert response.dependency == [
               "google.protobuf.Timestamp.proto",
               "google.protobuf.StringValue.proto"
             ]
    end

    test "should exclude nested types from dependenciy list", ctx do
      filename = "testserviceV3.TestRequest.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"

      assert response.dependency == [
               "testserviceV3.Enum.proto",
               "google.protobuf.Any.proto",
               "google.protobuf.StringValue.proto"
             ]
    end
  end

  describe "proto2 extensions" do
    test "should get all extension numbers by type", ctx do
      type = "testserviceV2.TestRequest"
      message = {:all_extension_numbers_of_type, type}
      assert {:ok, response} = run_request(message, ctx)
      assert response.base_type_name == type
      assert response.extension_number == [10, 11]
    end

    test "should get extension descriptor file by extendee", ctx do
      extendee = "testserviceV2.TestRequest"

      message =
        {:file_containing_extension,
         %Grpc.Reflection.V1.ExtensionRequest{containing_type: extendee, extension_number: 10}}

      assert {:ok, response} = run_request(message, ctx)
      assert response.name == extendee <> "Extension.proto"
      assert response.package == "testserviceV2"
      assert response.dependency == ["testserviceV2.TestRequest.proto"]

      assert [
               %Google.Protobuf.FieldDescriptorProto{name: "data"},
               %Google.Protobuf.FieldDescriptorProto{name: "location"}
             ] = response.extension

      assert [
               %Google.Protobuf.DescriptorProto{
                 name: "Location"
               }
             ] = response.message_type
    end
  end

  test "reflection graph is traversable", ctx do
    ops = GrpcReflection.TestClient.traverse_service(ctx)

    assert ops == [
             {:file_by_filename, "google.protobuf.Any.proto"},
             {:file_by_filename, "google.protobuf.StringValue.proto"},
             {:file_by_filename, "google.protobuf.Timestamp.proto"},
             {:file_by_filename, "grpc.reflection.v1.ErrorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ExtensionNumberResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ExtensionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1.FileDescriptorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ListServiceResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ServerReflectionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1.ServerReflectionResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ServiceResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ErrorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ExtensionNumberResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ExtensionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.FileDescriptorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ListServiceResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ServerReflectionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ServerReflectionResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ServiceResponse.proto"},
             {:file_by_filename, "helloworld.HelloReply.proto"},
             {:file_by_filename, "helloworld.HelloRequest.proto"},
             {:file_by_filename, "recursive_message.Reply.proto"},
             {:file_by_filename, "testserviceV2.Enum.proto"},
             {:file_by_filename, "testserviceV2.TestReply.proto"},
             {:file_by_filename, "testserviceV2.TestRequest.proto"},
             {:file_by_filename, "testserviceV3.Enum.proto"},
             {:file_by_filename, "testserviceV3.TestReply.proto"},
             {:file_by_filename, "testserviceV3.TestRequest.proto"},
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 10
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 11
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 12
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 13
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 14
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 15
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 16
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 17
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 18
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 19
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 20
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest",
                 extension_number: 21
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 10
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 11
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 12
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 13
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 14
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 15
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 16
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 17
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 18
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 19
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 20
               }
             },
             {
               :file_containing_extension,
               %Grpc.Reflection.V1.ExtensionRequest{
                 __unknown_fields__: [],
                 containing_type: "testserviceV2.TestRequest.GEntry",
                 extension_number: 21
               }
             },
             {:file_containing_symbol, ".grpc.reflection.v1.ServerReflectionRequest"},
             {:file_containing_symbol, ".grpc.reflection.v1.ServerReflectionResponse"},
             {:file_containing_symbol, ".grpc.reflection.v1alpha.ServerReflectionRequest"},
             {:file_containing_symbol, ".grpc.reflection.v1alpha.ServerReflectionResponse"},
             {:file_containing_symbol, ".helloworld.HelloReply"},
             {:file_containing_symbol, ".helloworld.HelloRequest"},
             {:file_containing_symbol, ".recursive_message.Reply"},
             {:file_containing_symbol, ".recursive_message.Request"},
             {:file_containing_symbol, ".testserviceV2.TestReply"},
             {:file_containing_symbol, ".testserviceV2.TestRequest"},
             {:file_containing_symbol, ".testserviceV3.TestReply"},
             {:file_containing_symbol, ".testserviceV3.TestRequest"},
             {:file_containing_symbol, "grpc.reflection.v1.ServerReflection"},
             {:file_containing_symbol, "grpc.reflection.v1alpha.ServerReflection"},
             {:file_containing_symbol, "helloworld.Greeter"},
             {:file_containing_symbol, "recursive_message.Service"},
             {:file_containing_symbol, "testserviceV2.TestService"},
             {:file_containing_symbol, "testserviceV3.TestService"},
             {:list_services, ""}
           ]
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert ops == [
             {:call, "grpc.reflection.v1.ServerReflection.ServerReflectionInfo"},
             {:call, "grpc.reflection.v1alpha.ServerReflection.ServerReflectionInfo"},
             {:call, "helloworld.Greeter.SayHello"},
             {:call, "testserviceV2.TestService.CallFunction"},
             {:call, "testserviceV3.TestService.CallFunction"},
             {:service, "grpc.reflection.v1.ServerReflection"},
             {:service, "grpc.reflection.v1alpha.ServerReflection"},
             {:service, "helloworld.Greeter"},
             {:service, "testserviceV2.TestService"},
             {:service, "testserviceV3.TestService"},
             {:type, ".google.protobuf.Any"},
             {:type, ".google.protobuf.StringValue"},
             {:type, ".google.protobuf.Timestamp"},
             {:type, ".grpc.reflection.v1.ErrorResponse"},
             {:type, ".grpc.reflection.v1.ExtensionNumberResponse"},
             {:type, ".grpc.reflection.v1.ExtensionRequest"},
             {:type, ".grpc.reflection.v1.FileDescriptorResponse"},
             {:type, ".grpc.reflection.v1.ListServiceResponse"},
             {:type, ".grpc.reflection.v1.ServerReflectionRequest"},
             {:type, ".grpc.reflection.v1.ServerReflectionResponse"},
             {:type, ".grpc.reflection.v1.ServiceResponse"},
             {:type, ".grpc.reflection.v1alpha.ErrorResponse"},
             {:type, ".grpc.reflection.v1alpha.ExtensionNumberResponse"},
             {:type, ".grpc.reflection.v1alpha.ExtensionRequest"},
             {:type, ".grpc.reflection.v1alpha.FileDescriptorResponse"},
             {:type, ".grpc.reflection.v1alpha.ListServiceResponse"},
             {:type, ".grpc.reflection.v1alpha.ServerReflectionRequest"},
             {:type, ".grpc.reflection.v1alpha.ServerReflectionResponse"},
             {:type, ".grpc.reflection.v1alpha.ServiceResponse"},
             {:type, ".helloworld.HelloReply"},
             {:type, ".helloworld.HelloRequest"},
             {:type, ".testserviceV2.Enum"},
             {:type, ".testserviceV2.TestReply"},
             {:type, ".testserviceV2.TestRequest"},
             {:type, ".testserviceV3.Enum"},
             {:type, ".testserviceV3.TestReply"},
             {:type, ".testserviceV3.TestRequest"}
           ]
  end
end
