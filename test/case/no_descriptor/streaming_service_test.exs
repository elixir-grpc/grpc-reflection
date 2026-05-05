defmodule GrpcReflection.Case.NoDescriptor.StreamingTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.Streaming.StreamingService.Service

  setup :stub_v1_server

  test "should list services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    assert Enum.map(service_list, &Map.get(&1, :name)) == ["streaming.StreamingService"]
  end

  test "should list methods on StreamingService with correct streaming flags", ctx do
    message = {:file_containing_symbol, "streaming.StreamingService"}
    assert {:ok, response} = run_request(message, ctx)

    assert %Google.Protobuf.FileDescriptorProto{
             package: "streaming",
             service: [
               %Google.Protobuf.ServiceDescriptorProto{
                 name: "StreamingService",
                 method: methods
               }
             ]
           } = response

    by_name = Map.new(methods, &{&1.name, &1})

    assert %{client_streaming: false, server_streaming: false} = by_name["UnaryCall"]
    assert %{client_streaming: false, server_streaming: true} = by_name["ServerStreamingCall"]
    assert %{client_streaming: true, server_streaming: false} = by_name["ClientStreamingCall"]

    assert %{client_streaming: true, server_streaming: true} =
             by_name["BidirectionalStreamingCall"]
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
