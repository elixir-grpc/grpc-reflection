defmodule GrpcReflection.Case.NoDescriptor.ScalarTypesTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.ScalarTypes.ScalarService.Service

  setup :stub_v1_server

  test "should list services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    assert Enum.map(service_list, &Map.get(&1, :name)) == ["scalar_types.ScalarService"]
  end

  test "should list methods on our service", ctx do
    message = {:file_containing_symbol, "scalar_types.ScalarService"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "scalar_types",
             service: [
               %Google.Protobuf.ServiceDescriptorProto{
                 name: "ScalarService",
                 method: [
                   %Google.Protobuf.MethodDescriptorProto{
                     name: "ProcessScalars",
                     input_type: ".scalar_types.ScalarRequest",
                     output_type: ".scalar_types.ScalarReply",
                     client_streaming: false,
                     server_streaming: false
                   }
                 ]
               }
             ]
           } = response
  end

  test "should reflect all scalar field types on ScalarRequest", ctx do
    message = {:file_containing_symbol, "scalar_types.ScalarRequest"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "scalar_types",
             message_type: [
               %Google.Protobuf.DescriptorProto{
                 name: "ScalarRequest",
                 field: fields
               }
             ]
           } = response

    by_name = Map.new(fields, &{&1.name, &1})

    assert %{type: :TYPE_DOUBLE, number: 1, label: :LABEL_OPTIONAL} = by_name["double_field"]
    assert %{type: :TYPE_FLOAT, number: 2, label: :LABEL_OPTIONAL} = by_name["float_field"]
    assert %{type: :TYPE_INT32, number: 3, label: :LABEL_OPTIONAL} = by_name["int32_field"]
    assert %{type: :TYPE_INT64, number: 4, label: :LABEL_OPTIONAL} = by_name["int64_field"]
    assert %{type: :TYPE_UINT32, number: 5, label: :LABEL_OPTIONAL} = by_name["uint32_field"]
    assert %{type: :TYPE_UINT64, number: 6, label: :LABEL_OPTIONAL} = by_name["uint64_field"]
    assert %{type: :TYPE_SINT32, number: 7, label: :LABEL_OPTIONAL} = by_name["sint32_field"]
    assert %{type: :TYPE_SINT64, number: 8, label: :LABEL_OPTIONAL} = by_name["sint64_field"]
    assert %{type: :TYPE_FIXED32, number: 9, label: :LABEL_OPTIONAL} = by_name["fixed32_field"]
    assert %{type: :TYPE_FIXED64, number: 10, label: :LABEL_OPTIONAL} = by_name["fixed64_field"]

    assert %{type: :TYPE_SFIXED32, number: 11, label: :LABEL_OPTIONAL} =
             by_name["sfixed32_field"]

    assert %{type: :TYPE_SFIXED64, number: 12, label: :LABEL_OPTIONAL} =
             by_name["sfixed64_field"]

    assert %{type: :TYPE_BOOL, number: 13, label: :LABEL_OPTIONAL} = by_name["bool_field"]
    assert %{type: :TYPE_STRING, number: 14, label: :LABEL_OPTIONAL} = by_name["string_field"]
    assert %{type: :TYPE_BYTES, number: 15, label: :LABEL_OPTIONAL} = by_name["bytes_field"]

    assert %{type: :TYPE_STRING, number: 100, label: :LABEL_OPTIONAL} = by_name["sparse_field_1"]

    assert %{type: :TYPE_STRING, number: 1000, label: :LABEL_OPTIONAL} =
             by_name["sparse_field_2"]

    assert %{type: :TYPE_STRING, number: 10_000, label: :LABEL_OPTIONAL} =
             by_name["sparse_field_3"]
  end

  test "should reflect proto3 optional fields with presence tracking", ctx do
    message = {:file_containing_symbol, "scalar_types.ScalarRequest"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             message_type: [%Google.Protobuf.DescriptorProto{field: fields}]
           } = response

    by_name = Map.new(fields, &{&1.name, &1})

    assert %{type: :TYPE_STRING, number: 18, proto3_optional: true} = by_name["optional_string"]
    assert %{type: :TYPE_INT32, number: 19, proto3_optional: true} = by_name["optional_int"]
  end

  test "should reflect repeated fields on ScalarReply", ctx do
    message = {:file_containing_symbol, "scalar_types.ScalarReply"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             message_type: [
               %Google.Protobuf.DescriptorProto{name: "ScalarReply", field: fields}
             ]
           } = response

    assert Enum.all?(fields, &(&1.label == :LABEL_REPEATED))
    by_name = Map.new(fields, &{&1.name, &1})
    assert %{type: :TYPE_DOUBLE} = by_name["double_list"]
    assert %{type: :TYPE_BYTES} = by_name["bytes_list"]
    assert %{type: :TYPE_BOOL} = by_name["bool_list"]
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert ops == [
             {:call, "scalar_types.ScalarService.ProcessScalars"},
             {:service, "scalar_types.ScalarService"}
           ]
  end
end
