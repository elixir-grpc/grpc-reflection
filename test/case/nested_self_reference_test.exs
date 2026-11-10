defmodule GrpcReflection.Case.NestedSelfReferenceTest do
  @moduledoc false

  use GrpcCase, service: NestedSelfReference.Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["nested_self_reference.Service"]
      end

      # a nested type that refers back to its enclosing message must not make the
      # file depend on itself
      test "no file lists itself as a dependency", ctx do
        for symbol <- ["nested_self_reference.Outer", "nested_self_reference.Outer.Inner"] do
          message = {:file_containing_symbol, symbol}
          assert {:ok, %Google.Protobuf.FileDescriptorProto{} = file} = run_request(message, ctx)
          refute file.name in file.dependency, "#{file.name} depends on itself"
        end
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "nested_self_reference.Service.call"} in ops
        assert {:service, "nested_self_reference.Service"} in ops
      end
    end
  end
end
