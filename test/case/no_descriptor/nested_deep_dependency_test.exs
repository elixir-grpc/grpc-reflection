defmodule GrpcReflection.Case.NoDescriptor.NestedDeepDependencyTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.NestedDeepDependency.Service.Service

  setup :stub_v1_server

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
