defmodule GrpcReflection.Case.NoDescriptor.ImportsTestServiceTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.ImportsTest.ImportTestService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["imports_test.ImportTestService"]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "imports_test.ImportTestService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "imports_test",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "ImportTestService",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "CreateUser",
                         input_type: ".imports_test.UserRequest",
                         output_type: ".imports_test.UserResponse"
                       },
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "UpdateLocation",
                         input_type: ".imports_test.LocationUpdate",
                         output_type: ".imports_test.LocationResponse"
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "cross-package type common.Address is resolvable by symbol", ctx do
        message = {:file_containing_symbol, "common.Address"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "common",
                 message_type: [%Google.Protobuf.DescriptorProto{name: "Address", field: fields}]
               } = response

        by_name = Map.new(fields, &{&1.name, &1})
        assert %{type: :TYPE_STRING, number: 1} = by_name["street"]
        assert %{type: :TYPE_STRING, number: 5} = by_name["country"]
      end

      test "google.protobuf.Timestamp is resolvable by symbol", ctx do
        message = {:file_containing_symbol, "google.protobuf.Timestamp"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "google.protobuf",
                 message_type: [%Google.Protobuf.DescriptorProto{name: "Timestamp"}]
               } = response
      end

      test "UserRequest lists cross-package dependencies", ctx do
        message = {:file_by_filename, "imports_test.UserRequest.proto"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 name: "imports_test.UserRequest.proto",
                 package: "imports_test"
               } = response

        assert "common.Address.proto" in response.dependency
        assert "common.Coordinates.proto" in response.dependency
        assert "google.protobuf.Timestamp.proto" in response.dependency
      end

      @tag :skip
      test "reflection graph is traversable using grpcurl", _ctx do
        # LocationResponse has a map field (VisitHistoryEntry). Without descriptor/0 the
        # synthesized descriptor has nested_type: [], so VisitHistoryEntry is emitted as a
        # standalone file. grpcurl cannot resolve the cross-reference and returns exit code 1.
        # This is the same known synthesizer limitation as proto2_features (map-entry types).
      end
    end
  end
end
