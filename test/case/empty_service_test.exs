defmodule GrpcReflection.Case.EmptyServiceTest do
  @moduledoc false

  use GrpcCase, service: EmptyService.EmptyService.Service

  describe "v1" do
    setup :stub_v1_server

    test "unsupported call is rejected", ctx do
      message = {:file_containing_extension, %Grpc.Reflection.V1.ExtensionRequest{}}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should list services", ctx do
      message = {:list_services, ""}
      assert {:ok, %{service: service_list}} = run_request(message, ctx)
      assert Enum.map(service_list, &Map.get(&1, :name)) == ["empty_service.EmptyService"]
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "empty_service.EmptyService"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               package: "empty_service",
               dependency: [],
               service: [
                 %Google.Protobuf.ServiceDescriptorProto{
                   name: "EmptyService",
                   method: []
                 }
               ]
             } = response
    end

    test "reflection graph is traversable using grpcurl", ctx do
      ops = GrpcReflection.TestClient.grpcurl_service(ctx)
      assert ops == [service: "empty_service.EmptyService"]
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
      assert Enum.map(service_list, &Map.get(&1, :name)) == ["empty_service.EmptyService"]
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "empty_service.EmptyService"}
      assert {:ok, response} = run_request(message, ctx)

      assert %Google.Protobuf.FileDescriptorProto{
               package: "empty_service",
               dependency: [],
               service: [
                 %Google.Protobuf.ServiceDescriptorProto{
                   name: "EmptyService",
                   method: []
                 }
               ]
             } = response
    end

    test "reflection graph is traversable using grpcurl", ctx do
      ops = GrpcReflection.TestClient.grpcurl_service(ctx)

      assert ops == [service: "empty_service.EmptyService"]
    end
  end
end
