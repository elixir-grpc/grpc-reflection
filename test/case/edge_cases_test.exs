defmodule GrpcReflection.Case.EdgeCasesTest do
  @moduledoc false

  use GrpcCase, service: EdgeCases.EdgeCaseService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

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
                     name: "EdgeCaseService"
                   }
                 ]
               } = response
      end

      test "empty request message has no fields", ctx do
        message = {:file_containing_symbol, "edge_cases.EmptyInputRequest"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [
                   %Google.Protobuf.DescriptorProto{name: "EmptyInputRequest", field: []}
                 ]
               } = response
      end

      test "message with only a response field reflects correctly", ctx do
        message = {:file_containing_symbol, "edge_cases.EmptyInputResponse"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [
                   %Google.Protobuf.DescriptorProto{
                     name: "EmptyInputResponse",
                     field: [
                       %Google.Protobuf.FieldDescriptorProto{
                         name: "data",
                         number: 1,
                         type: :TYPE_STRING,
                         label: :LABEL_OPTIONAL
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "edge_cases.EdgeCaseService.BothEmpty"},
                 {:call, "edge_cases.EdgeCaseService.EmptyInput"},
                 {:call, "edge_cases.EdgeCaseService.EmptyOutput"},
                 {:service, "edge_cases.EdgeCaseService"}
               ]
      end
    end
  end
end
