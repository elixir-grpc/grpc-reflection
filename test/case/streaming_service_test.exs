defmodule GrpcReflection.Case.StreamingTest do
  @moduledoc false

  use GrpcCase, service: Streaming.StreamingService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        expected_services = ["streaming.StreamingService"]
        assert Enum.map(service_list, &Map.get(&1, :name)) == expected_services
      end

      test "should list methods on StreamingService", ctx do
        message = {:file_containing_symbol, "streaming.StreamingService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "streaming"
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "streaming.StreamingService.BidirectionalStreamingCall"},
                 {:call, "streaming.StreamingService.ClientStreamingCall"},
                 {:call, "streaming.StreamingService.ServerStreamingCall"},
                 {:call, "streaming.StreamingService.UnaryCall"},
                 {:service, "streaming.StreamingService"},
                 {:type, ".streaming.StreamRequest"},
                 {:type, ".streaming.StreamResponse"}
               ]
      end
    end
  end
end
