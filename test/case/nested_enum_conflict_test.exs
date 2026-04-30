defmodule GrpcReflection.Case.NestedEnumConflictTest do
  @moduledoc false

  use GrpcCase, service: NestedEnumConflict.ConflictService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)

        assert Enum.map(service_list, &Map.get(&1, :name)) == [
                 "nestedEnumConflict.ConflictService"
               ]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "nestedEnumConflict.ConflictService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "nestedEnumConflict",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "ConflictService",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{name: "ListFoos"},
                       %Google.Protobuf.MethodDescriptorProto{name: "ListBars"}
                     ]
                   }
                 ]
               } = response
      end

      test "messages with identically-named nested enums are each resolvable", ctx do
        for symbol <- [
              "nestedEnumConflict.ListFoosRequest",
              "nestedEnumConflict.ListBarsRequest"
            ] do
          message = {:file_containing_symbol, symbol}

          assert {:ok, %Google.Protobuf.FileDescriptorProto{package: "nestedEnumConflict"}} =
                   run_request(message, ctx)
        end
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert ops == [
                 {:call, "nestedEnumConflict.ConflictService.ListBars"},
                 {:call, "nestedEnumConflict.ConflictService.ListFoos"},
                 {:service, "nestedEnumConflict.ConflictService"},
                 {:type, ".nestedEnumConflict.ListBarsRequest"},
                 {:type, ".nestedEnumConflict.ListBarsRequest.SortOrder"},
                 {:type, ".nestedEnumConflict.ListBarsResponse"},
                 {:type, ".nestedEnumConflict.ListFoosRequest"},
                 {:type, ".nestedEnumConflict.ListFoosRequest.SortOrder"},
                 {:type, ".nestedEnumConflict.ListFoosResponse"}
               ]
      end
    end
  end
end
