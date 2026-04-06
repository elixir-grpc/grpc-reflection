defmodule GrpcReflection.Case.CustomPrefixServiceTest do
  @moduledoc false

  use GrpcCase, service: CustomizedPrefix.PrefixService.Service

  describe "v1" do
    setup :stub_v1_server

    test "unsupported call is rejected", ctx do
      message = {:file_containing_extension, %Grpc.Reflection.V1.ExtensionRequest{}}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should list services", ctx do
      message = {:list_services, ""}
      assert {:ok, %{service: service_list}} = run_request(message, ctx)
      assert Enum.map(service_list, &Map.get(&1, :name)) == ["custom_prefix.PrefixService"]
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "custom_prefix.PrefixService"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               package: "custom_prefix",
               dependency: ["custom_prefix.EchoRequest.proto", "custom_prefix.EchoResponse.proto"],
               service: [
                 %Google.Protobuf.ServiceDescriptorProto{
                   name: "PrefixService",
                   method: [
                     %Google.Protobuf.MethodDescriptorProto{
                       name: "Echo",
                       input_type: ".custom_prefix.EchoRequest",
                       output_type: ".custom_prefix.EchoResponse"
                     }
                   ]
                 }
               ]
             } = response
    end

    test "should return the service when requesting a method on the service", ctx do
      message = {:file_containing_symbol, "custom_prefix.PrefixService.Echo"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               service: [
                 %Google.Protobuf.ServiceDescriptorProto{
                   name: "PrefixService",
                   method: [
                     %Google.Protobuf.MethodDescriptorProto{
                       name: "Echo"
                     }
                   ]
                 }
               ]
             } = response
    end

    test "should resolve a type", ctx do
      message = {:file_containing_symbol, ".custom_prefix.EchoRequest"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               message_type: [
                 %Google.Protobuf.DescriptorProto{
                   name: "EchoRequest",
                   field: [
                     %Google.Protobuf.FieldDescriptorProto{
                       name: "message"
                     }
                   ]
                 }
               ]
             } = response
    end

    test "reflection graph is traversable using grpcurl", ctx do
      ops = GrpcReflection.TestClient.grpcurl_service(ctx)

      assert ops == [
               call: "custom_prefix.PrefixService.Echo",
               service: "custom_prefix.PrefixService"
             ]
    end
  end

  describe "v1alpha" do
    setup :stub_v1alpha_server

    test "unsupported call is rejected", ctx do
      message = {:file_containing_extension, %Grpc.Reflection.V1alpha.ExtensionRequest{}}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should list services", ctx do
      message = {:list_services, ""}
      assert {:ok, %{service: service_list}} = run_request(message, ctx)
      assert Enum.map(service_list, &Map.get(&1, :name)) == ["custom_prefix.PrefixService"]
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "custom_prefix.PrefixService"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               package: "custom_prefix",
               dependency: ["custom_prefix.EchoRequest.proto", "custom_prefix.EchoResponse.proto"],
               service: [
                 %Google.Protobuf.ServiceDescriptorProto{
                   name: "PrefixService",
                   method: [
                     %Google.Protobuf.MethodDescriptorProto{
                       name: "Echo",
                       input_type: ".custom_prefix.EchoRequest",
                       output_type: ".custom_prefix.EchoResponse"
                     }
                   ]
                 }
               ]
             } = response
    end

    test "should return the service when requesting a method on the service", ctx do
      message = {:file_containing_symbol, "custom_prefix.PrefixService.Echo"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               service: [
                 %Google.Protobuf.ServiceDescriptorProto{
                   name: "PrefixService",
                   method: [
                     %Google.Protobuf.MethodDescriptorProto{
                       name: "Echo"
                     }
                   ]
                 }
               ]
             } = response
    end

    test "should resolve a type", ctx do
      message = {:file_containing_symbol, ".custom_prefix.EchoRequest"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               message_type: [
                 %Google.Protobuf.DescriptorProto{
                   name: "EchoRequest",
                   field: [
                     %Google.Protobuf.FieldDescriptorProto{
                       name: "message"
                     }
                   ]
                 }
               ]
             } = response
    end

    test "reflection graph is traversable using grpcurl", ctx do
      ops = GrpcReflection.TestClient.grpcurl_service(ctx)

      assert ops == [
               call: "custom_prefix.PrefixService.Echo",
               service: "custom_prefix.PrefixService"
             ]
    end
  end
end
