defmodule GrpcReflection.Case.NestedDeepDependencyTest do
  @moduledoc false

  use GrpcCase, service: NestedDeepDependency.Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      # External is only used by Outer.Middle.Deep, three levels down, but a client still
      # has to load it before it can use the file that declares Outer
      test "types used by deeply nested messages are file dependencies", ctx do
        message = {:file_containing_symbol, "nested_deep_dependency.Outer"}

        assert {:ok, %Google.Protobuf.FileDescriptorProto{dependency: deps}} =
                 run_request(message, ctx)

        assert deps == ["nested_deep_dependency.External.proto"]
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "nested_deep_dependency.Service.call"} in ops
        assert {:type, ".nested_deep_dependency.External"} in ops
      end
    end
  end
end
