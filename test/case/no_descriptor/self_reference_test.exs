defmodule GrpcReflection.Case.NoDescriptor.SelfReferenceTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.SelfReference.Service.Service

  setup :stub_v1_server

  test "should list services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    assert Enum.map(service_list, &Map.get(&1, :name)) == ["self_reference.Service"]
  end

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
