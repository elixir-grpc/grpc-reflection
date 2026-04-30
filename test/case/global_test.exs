defmodule GrpcReflection.Case.GlobalTest do
  @moduledoc false

  use GrpcCase, service: GlobalService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["GlobalService"]
      end

      test "should list methods on service with no package", ctx do
        message = {:file_containing_symbol, "GlobalService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "GlobalService",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "GlobalMethod",
                         input_type: ".GlobalRequest",
                         output_type: ".GlobalResponse"
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "GlobalService.GlobalMethod"},
                 {:service, "GlobalService"},
                 {:type, ".GlobalRequest"},
                 {:type, ".GlobalResponse"}
               ]
      end
    end
  end
end
