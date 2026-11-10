defmodule GrpcReflection.Case.NoDescriptor.NestedCrossReferenceTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.NestedCrossReference.Service.Service

  setup :stub_v1_server

  test "nested types are embedded in the file of the message that declares them", ctx do
    message = {:file_containing_symbol, "nested_cross_reference.Holder.Item"}
    assert {:ok, %Google.Protobuf.FileDescriptorProto{} = file} = run_request(message, ctx)

    assert file.name == "nested_cross_reference.Holder.proto"
    assert file.package == "nested_cross_reference"
    assert [%{name: "Holder", nested_type: nested, enum_type: enums}] = file.message_type
    assert Enum.map(nested, & &1.name) == ["Item"]
    assert Enum.map(enums, & &1.name) == ["Kind"]
  end

  test "map entries are marked as map entries", ctx do
    message = {:file_containing_symbol, "nested_cross_reference.Request"}
    assert {:ok, %Google.Protobuf.FileDescriptorProto{} = file} = run_request(message, ctx)

    assert [%{name: "Request", nested_type: [entry]}] = file.message_type
    assert entry.name == "ItemsEntry"
    assert %Google.Protobuf.MessageOptions{map_entry: true} = entry.options
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "nested_cross_reference.Service.call"} in ops
    assert {:call, "nested_cross_reference.Service.callItem"} in ops
    assert {:type, ".nested_cross_reference.Holder.Item"} in ops
  end
end
