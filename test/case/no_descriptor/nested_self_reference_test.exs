defmodule GrpcReflection.Case.NoDescriptor.NestedSelfReferenceTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.NestedSelfReference.Service.Service

  setup :stub_v1_server

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
