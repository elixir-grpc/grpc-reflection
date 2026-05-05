defmodule GrpcReflection.Case.NoDescriptor.EdgeCasesTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.EdgeCases.EdgeCaseService.Service

  setup :stub_v1_server

  test "should list services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    assert Enum.map(service_list, &Map.get(&1, :name)) == ["edge_cases.EdgeCaseService"]
  end

  test "should list methods on our service", ctx do
    message = {:file_containing_symbol, "edge_cases.EdgeCaseService"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "edge_cases",
             service: [
               %Google.Protobuf.ServiceDescriptorProto{
                 name: "EdgeCaseService",
                 method: methods
               }
             ]
           } = response

    by_name = Map.new(methods, &{&1.name, &1})
    assert %{input_type: ".edge_cases.EmptyInputRequest"} = by_name["EmptyInput"]
    assert %{output_type: ".edge_cases.EmptyOutputResponse"} = by_name["EmptyOutput"]
    assert %{input_type: ".edge_cases.BothEmptyRequest"} = by_name["BothEmpty"]
  end

  test "empty message has no fields", ctx do
    message = {:file_containing_symbol, "edge_cases.BothEmptyRequest"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "edge_cases",
             message_type: [
               %Google.Protobuf.DescriptorProto{name: "BothEmptyRequest", field: []}
             ]
           } = response
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "edge_cases.EdgeCaseService.BothEmpty"} in ops
    assert {:call, "edge_cases.EdgeCaseService.EmptyInput"} in ops
    assert {:call, "edge_cases.EdgeCaseService.EmptyOutput"} in ops
    assert {:service, "edge_cases.EdgeCaseService"} in ops
  end
end
