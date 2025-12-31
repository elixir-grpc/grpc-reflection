defmodule GrpcReflection.V1alphaReflectionTest do
  @moduledoc false

  use GrpcCase
  use GrpcReflection.TestClient, version: :v1alpha

  @moduletag capture_log: true

  test "unsupported call is rejected", ctx do
    message = {:file_containing_extension, %Grpc.Reflection.V1alpha.ExtensionRequest{}}
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
             "grpc.reflection.v1alpha.ServerReflection"
           ]
  end

  describe "symbol queries" do
    test "should reject unknown symbol", ctx do
      message = {:file_containing_symbol, "other.Rejecter"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should resolve the service when describing a method", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter.SayHello"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return not found for an invalid method", ctx do
      # SayHellp is not a method on the service
      message = {:file_containing_symbol, "helloworld.Greeter.SayHellp"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should return the type when it is the root typy", ctx do
      message = {:file_containing_symbol, "helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return the containing type for a query on a nested type", ctx do
      message = {:file_containing_symbol, "testserviceV3.TestRequest.Payload"}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == "testserviceV3.TestRequest.proto"
    end

    test "should also resove with leading period", ctx do
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

    test "should reject a filename that isn't recognized", ctx do
      filename = "does.not.exist.proto"
      message = {:file_by_filename, filename}
      assert {:error, _} = run_request(message, ctx)
    end

    test "gshould resolve by filename", ctx do
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
                   %Google.Protobuf.FieldDescriptorProto{name: "message"},
                   %Google.Protobuf.FieldDescriptorProto{name: "today"}
                 ]
               }
             ] = response.message_type
    end

    test "should resolve third party messages by filename", ctx do
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

    test "should not duplicate dependencies", ctx do
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

    test "should not treat a nested type as a dependency", ctx do
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
         %Grpc.Reflection.V1alpha.ExtensionRequest{
           containing_type: extendee,
           extension_number: 10
         }}

      assert {:ok, response} = run_request(message, ctx)
      assert response.name == extendee <> "Extension.proto"
      assert response.package == "testserviceV2"
      assert response.dependency == ["testserviceV2.TestRequest.proto"]

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
             {:file_by_filename, "testserviceV2.Enum.proto"},
             {:file_by_filename, "testserviceV2.TestReply.proto"},
             {:file_by_filename, "testserviceV2.TestRequest.proto"},
             {:file_by_filename, "testserviceV3.Enum.proto"},
             {:file_by_filename, "testserviceV3.TestReply.proto"},
             {:file_by_filename, "testserviceV3.TestRequest.proto"},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 10,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 11,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 12,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 13,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 14,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 15,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 16,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 17,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 18,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 19,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 20,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 21,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 10,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 11,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 12,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 13,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 14,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 15,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 16,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 17,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 18,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 19,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 20,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1alpha.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 21,
                __unknown_fields__: []
              }},
             {:file_containing_symbol, ".grpc.reflection.v1.ServerReflectionRequest"},
             {:file_containing_symbol, ".grpc.reflection.v1.ServerReflectionResponse"},
             {:file_containing_symbol, ".grpc.reflection.v1alpha.ServerReflectionRequest"},
             {:file_containing_symbol, ".grpc.reflection.v1alpha.ServerReflectionResponse"},
             {:file_containing_symbol, ".helloworld.HelloReply"},
             {:file_containing_symbol, ".helloworld.HelloRequest"},
             {:file_containing_symbol, ".testserviceV2.TestReply"},
             {:file_containing_symbol, ".testserviceV2.TestRequest"},
             {:file_containing_symbol, ".testserviceV3.TestReply"},
             {:file_containing_symbol, ".testserviceV3.TestRequest"},
             {:file_containing_symbol, "grpc.reflection.v1.ServerReflection"},
             {:file_containing_symbol, "grpc.reflection.v1alpha.ServerReflection"},
             {:file_containing_symbol, "helloworld.Greeter"},
             {:file_containing_symbol, "testserviceV2.TestService"},
             {:file_containing_symbol, "testserviceV3.TestService"},
             {:list_services, ""}
           ]
  end
end
