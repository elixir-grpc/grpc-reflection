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
