defmodule GrpcReflection.Case.SelfReferenceTest do
  @moduledoc false

  use GrpcCase, service: SelfReference.Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["self_reference.Service"]
      end

      # a client resolves every dependency before it can use a file, so a file that
      # depends on itself sends it into an endless loop (grpcurl: stack overflow)
      test "no file lists itself as a dependency", ctx do
        message = {:file_containing_symbol, "self_reference.Request"}
        assert {:ok, %Google.Protobuf.FileDescriptorProto{} = file} = run_request(message, ctx)
        refute file.name in file.dependency, "#{file.name} depends on itself"
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "self_reference.Service.call"} in ops
        assert {:service, "self_reference.Service"} in ops
      end
    end
  end
end
