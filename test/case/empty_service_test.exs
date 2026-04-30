defmodule GrpcReflection.Case.EmptyServiceTest do
  @moduledoc false

  use GrpcCase, service: EmptyService.EmptyService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

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
end
