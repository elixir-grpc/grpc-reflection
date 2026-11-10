defmodule GrpcReflection.Case.NoDescriptor.NestedCycleTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.NestedCycle.Service.Service

  setup :stub_v1_server

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "nested_cycle.Service.call"} in ops
    assert {:type, ".nested_cycle.Second.Inner"} in ops
  end
end
