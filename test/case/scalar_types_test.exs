defmodule GrpcReflection.Case.ScalarTypesTest do
  @moduledoc false

  use GrpcCase, service: ScalarTypes.ScalarService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["scalar_types.ScalarService"]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "scalar_types.ScalarService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "scalar_types",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "ScalarService",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "ProcessScalars"
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "scalar_types.ScalarService.ProcessScalars"},
                 {:service, "scalar_types.ScalarService"}
               ]
      end
    end
  end
end
