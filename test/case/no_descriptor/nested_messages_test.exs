defmodule GrpcReflection.Case.NoDescriptor.NestedMessagesTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.Nested.NestedService.Service

  setup :stub_v1_server

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "nested.NestedService.ProcessNested"} in ops
    assert {:service, "nested.NestedService"} in ops
  end
end
