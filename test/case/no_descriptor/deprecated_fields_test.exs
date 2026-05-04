defmodule GrpcReflection.Case.NoDescriptor.DeprecatedFieldsTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Service

  setup :stub_v1_server

  test "should list services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)

    assert Enum.map(service_list, &Map.get(&1, :name)) == [
             "deprecated_fields.DeprecatedFieldsService"
           ]
  end

  test "deprecated fields carry options.deprecated true, active fields do not", ctx do
    message = {:file_containing_symbol, "deprecated_fields.DeprecatedRequest"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "deprecated_fields",
             message_type: [
               %Google.Protobuf.DescriptorProto{name: "DeprecatedRequest", field: fields}
             ]
           } = response

    by_name = Map.new(fields, &{&1.name, &1})

    assert %{options: nil} = by_name["active_field"]
    assert %{options: nil} = by_name["active_id"]

    assert %{options: %Google.Protobuf.FieldOptions{deprecated: true}} =
             by_name["legacy_field"]

    assert %{options: %Google.Protobuf.FieldOptions{deprecated: true}} = by_name["old_id"]
  end

  test "deprecated field on response also carries options.deprecated true", ctx do
    message = {:file_containing_symbol, "deprecated_fields.DeprecatedResponse"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             message_type: [
               %Google.Protobuf.DescriptorProto{name: "DeprecatedResponse", field: fields}
             ]
           } = response

    by_name = Map.new(fields, &{&1.name, &1})

    assert %{options: nil} = by_name["success"]
    assert %{options: nil} = by_name["result"]
    assert %{options: %Google.Protobuf.FieldOptions{deprecated: true}} = by_name["old_result"]
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "deprecated_fields.DeprecatedFieldsService.Process"} in ops
    assert {:service, "deprecated_fields.DeprecatedFieldsService"} in ops
  end
end
