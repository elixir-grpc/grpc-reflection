defmodule GrpcReflection.Case.Proto2FeaturesTest do
  @moduledoc false

  use GrpcCase, service: Proto2Features.Proto2Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["proto2_features.Proto2Service"]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "proto2_features.Proto2Service"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "proto2_features"
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "proto2_features.Proto2Service.ProcessProto2"},
                 {:service, "proto2_features.Proto2Service"}
               ]
      end
    end
  end
end
