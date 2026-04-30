defmodule GrpcReflection.Case.ImportsTestServiceTest do
  @moduledoc false

  use GrpcCase, service: ImportsTest.ImportTestService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["imports_test.ImportTestService"]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "imports_test.ImportTestService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "imports_test",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "ImportTestService"
                   }
                 ]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "imports_test.ImportTestService.CreateUser"},
                 {:call, "imports_test.ImportTestService.UpdateLocation"},
                 {:service, "imports_test.ImportTestService"}
               ]
      end
    end
  end
end
