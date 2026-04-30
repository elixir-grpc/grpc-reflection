defmodule GrpcReflection.Case.RecursiveMessageTest do
  @moduledoc false

  use GrpcCase, service: RecursiveMessage.Service.Service

  # Recursive message structures cause infinite loops in the builder's graph traversal.
  # Tracked for future fix; protos and tests are in place to validate when resolved.
  @moduletag :skip

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["recursive_message.Service"]
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "recursive_message.Service.call"} in ops
        assert {:service, "recursive_message.Service"} in ops
      end
    end
  end
end
