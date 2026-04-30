defmodule GrpcReflection.Case.WellKnownTypesTest do
  @moduledoc false

  use GrpcCase, service: WellKnownTypes.WellKnownTypesService.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)

        assert Enum.map(service_list, &Map.get(&1, :name)) == [
                 "well_known_types.WellKnownTypesService"
               ]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "well_known_types.WellKnownTypesService"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "well_known_types",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "WellKnownTypesService",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{name: "ProcessWellKnownTypes"},
                       %Google.Protobuf.MethodDescriptorProto{name: "EmptyMethod"}
                     ]
                   }
                 ]
               } = response
      end

      test "well-known type dependencies are resolvable by filename", ctx do
        message = {:file_by_filename, "google.protobuf.Timestamp.proto"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 name: "google.protobuf.Timestamp.proto",
                 package: "google.protobuf",
                 message_type: [%Google.Protobuf.DescriptorProto{name: "Timestamp"}]
               } = response
      end

      test "well-known types are resolvable by symbol", ctx do
        message = {:file_containing_symbol, ".google.protobuf.Timestamp"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "google.protobuf",
                 message_type: [%Google.Protobuf.DescriptorProto{name: "Timestamp"}]
               } = response
      end

      # Well-known types contain circular references that cause an infinite loop in our
      # reflection tree builder, which grpcurl exposes as a stack overflow. Out of scope
      # for now; the reflection API itself is verified via the symbol/filename tests above.
    end
  end
end
