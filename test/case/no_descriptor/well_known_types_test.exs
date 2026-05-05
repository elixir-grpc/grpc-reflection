defmodule GrpcReflection.Case.NoDescriptor.WellKnownTypesTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.WellKnownTypes.WellKnownTypesService.Service

  setup :stub_v1_server

  test "should list services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)

    assert Enum.map(service_list, &Map.get(&1, :name)) == [
             "well_known_types.WellKnownTypesService"
           ]
  end

  test "should list methods on our service", ctx do
    message = {:file_containing_symbol, "well_known_types.WellKnownTypesService"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "well_known_types",
             service: [
               %Google.Protobuf.ServiceDescriptorProto{
                 name: "WellKnownTypesService",
                 method: [
                   %Google.Protobuf.MethodDescriptorProto{
                     name: "ProcessWellKnownTypes",
                     input_type: ".well_known_types.WellKnownRequest",
                     output_type: ".well_known_types.WellKnownResponse"
                   },
                   %Google.Protobuf.MethodDescriptorProto{
                     name: "EmptyMethod",
                     input_type: ".google.protobuf.Empty",
                     output_type: ".google.protobuf.Empty"
                   }
                 ]
               }
             ]
           } = response
  end

  test "well-known type Timestamp is resolvable by symbol", ctx do
    message = {:file_containing_symbol, "google.protobuf.Timestamp"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "google.protobuf",
             message_type: [%Google.Protobuf.DescriptorProto{name: "Timestamp"}]
           } = response
  end

  test "well-known type Any is resolvable by symbol", ctx do
    message = {:file_containing_symbol, "google.protobuf.Any"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "google.protobuf",
             message_type: [%Google.Protobuf.DescriptorProto{name: "Any"}]
           } = response
  end

  test "WellKnownRequest fields reference google.protobuf types", ctx do
    message = {:file_containing_symbol, "well_known_types.WellKnownRequest"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "well_known_types",
             message_type: [
               %Google.Protobuf.DescriptorProto{name: "WellKnownRequest", field: fields}
             ]
           } = response

    by_name = Map.new(fields, &{&1.name, &1})
    assert %{type: :TYPE_MESSAGE, type_name: ".google.protobuf.Any"} = by_name["payload"]

    assert %{type: :TYPE_MESSAGE, type_name: ".google.protobuf.Timestamp"} =
             by_name["created_at"]

    assert %{type: :TYPE_MESSAGE, type_name: ".google.protobuf.Duration"} = by_name["timeout"]

    assert %{type: :TYPE_MESSAGE, type_name: ".google.protobuf.FieldMask"} =
             by_name["field_mask"]
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "well_known_types.WellKnownTypesService.ProcessWellKnownTypes"} in ops
    assert {:call, "well_known_types.WellKnownTypesService.EmptyMethod"} in ops
    assert {:service, "well_known_types.WellKnownTypesService"} in ops
  end
end
