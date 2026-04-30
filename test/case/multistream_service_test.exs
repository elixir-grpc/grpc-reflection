defmodule GrpcReflection.Case.MultiStreamingTest do
  @moduledoc false

  use GrpcCase, service: Streaming.MultiStreamService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        expected_services = ["streaming.MultiStreamService"]
        assert Enum.map(service_list, &Map.get(&1, :name)) == expected_services
      end

      test "should list methods on MultiStreamService with correct streaming flags", ctx do
        message = {:file_containing_symbol, "streaming.MultiStreamService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "streaming",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "MultiStreamService",
                     method: methods
                   }
                 ]
               } = response

        by_name = Map.new(methods, &{&1.name, &1})

        assert %{client_streaming: true, server_streaming: false} = by_name["UploadData"]
        assert %{client_streaming: false, server_streaming: true} = by_name["DownloadData"]
        assert %{client_streaming: true, server_streaming: true} = by_name["SyncData"]
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "streaming.MultiStreamService.DownloadData"},
                 {:call, "streaming.MultiStreamService.SyncData"},
                 {:call, "streaming.MultiStreamService.UploadData"},
                 {:service, "streaming.MultiStreamService"},
                 {:type, ".streaming.DataChunk"},
                 {:type, ".streaming.DownloadRequest"},
                 {:type, ".streaming.UploadStatus"}
               ]
      end
    end
  end
end
