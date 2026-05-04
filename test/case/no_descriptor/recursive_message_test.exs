defmodule GrpcReflection.Case.NoDescriptor.RecursiveMessageTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.RecursiveMessage.Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["recursive_message.Service"]
      end

      test "should list methods on our service with lowercase rpc name", ctx do
        message = {:file_containing_symbol, "recursive_message.Service"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "recursive_message",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "Service",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "call",
                         input_type: ".recursive_message.Request",
                         output_type: ".recursive_message.Reply",
                         client_streaming: false,
                         server_streaming: false
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "recursive_message.Service.call"} in ops
        assert {:service, "recursive_message.Service"} in ops
      end
    end
  end
end
