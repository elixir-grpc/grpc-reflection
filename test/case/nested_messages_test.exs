defmodule GrpcReflection.Case.NestedMessagesTest do
  @moduledoc false

  use GrpcCase, service: Nested.NestedService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["nested.NestedService"]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "nested.NestedService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "nested",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "NestedService",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "ProcessNested",
                         input_type: ".nested.OuterMessage",
                         output_type: ".nested.OuterResponse"
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "should resolve a deeply nested type by symbol", ctx do
        message = {:file_containing_symbol, "nested.OuterMessage"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "nested",
                 message_type: [
                   %Google.Protobuf.DescriptorProto{
                     name: "OuterMessage",
                     nested_type: [_ | _]
                   }
                 ]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "nested.NestedService.ProcessNested"} in ops
        assert {:service, "nested.NestedService"} in ops
      end
    end
  end
end
