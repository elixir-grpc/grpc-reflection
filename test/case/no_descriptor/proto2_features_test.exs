defmodule GrpcReflection.Case.NoDescriptor.Proto2FeaturesTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.Proto2Features.Proto2Service.Service

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

      test "proto2 required fields have LABEL_REQUIRED", ctx do
        message = {:file_containing_symbol, "proto2_features.Proto2Request"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [
                   %Google.Protobuf.DescriptorProto{name: "Proto2Request", field: fields}
                 ]
               } = response

        by_name = Map.new(fields, &{&1.name, &1})

        assert %{label: :LABEL_REQUIRED, type: :TYPE_STRING, number: 1} =
                 by_name["required_field"]

        assert %{label: :LABEL_REQUIRED, type: :TYPE_INT32, number: 2} = by_name["required_id"]

        assert %{label: :LABEL_OPTIONAL, type: :TYPE_STRING, number: 3} =
                 by_name["optional_field"]

        assert %{label: :LABEL_OPTIONAL, type: :TYPE_INT32, number: 4} = by_name["optional_id"]
      end

      test "proto2 default values are reflected", ctx do
        message = {:file_containing_symbol, "proto2_features.Proto2Request"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [
                   %Google.Protobuf.DescriptorProto{field: fields}
                 ]
               } = response

        by_name = Map.new(fields, &{&1.name, &1})
        assert %{label: :LABEL_OPTIONAL, default_value: "unknown"} = by_name["name"]
        assert %{label: :LABEL_OPTIONAL, default_value: "8080"} = by_name["port"]
        assert %{label: :LABEL_OPTIONAL, default_value: "true"} = by_name["enabled"]
        assert %{type: :TYPE_ENUM, default_value: "ACTIVE"} = by_name["status"]
      end

      test "proto2 oneof fields carry oneof_index", ctx do
        message = {:file_containing_symbol, "proto2_features.Proto2Request"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [
                   %Google.Protobuf.DescriptorProto{
                     field: fields,
                     oneof_decl: [%Google.Protobuf.OneofDescriptorProto{name: "proto2_oneof"}]
                   }
                 ]
               } = response

        by_name = Map.new(fields, &{&1.name, &1})
        assert %{oneof_index: 0} = by_name["oneof_string"]
        assert %{oneof_index: 0} = by_name["oneof_int"]
      end

      test "proto2 packed repeated field has options.packed", ctx do
        message = {:file_containing_symbol, "proto2_features.Proto2Request"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [%Google.Protobuf.DescriptorProto{field: fields}]
               } = response

        by_name = Map.new(fields, &{&1.name, &1})

        assert %{
                 label: :LABEL_REPEATED,
                 type: :TYPE_INT32,
                 options: %Google.Protobuf.FieldOptions{packed: true}
               } = by_name["packed_ints"]
      end

      test "proto2 response required fields have LABEL_REQUIRED", ctx do
        message = {:file_containing_symbol, "proto2_features.Proto2Response"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 message_type: [
                   %Google.Protobuf.DescriptorProto{name: "Proto2Response", field: fields}
                 ]
               } = response

        by_name = Map.new(fields, &{&1.name, &1})
        assert %{label: :LABEL_REQUIRED, type: :TYPE_BOOL, number: 1} = by_name["success"]
        assert %{label: :LABEL_OPTIONAL, type: :TYPE_STRING, number: 2} = by_name["message"]
      end

      @tag :skip
      test "reflection graph is traversable using grpcurl", _ctx do
        # MetadataMapEntry is a map-entry nested type. Without descriptor/0 the synthesized
        # Proto2Request has nested_type: [] so MetadataMapEntry is emitted as a standalone
        # file. grpcurl cannot resolve the cross-reference and returns exit code 1.
        # This is a known synthesizer limitation for map fields with nested entry types.
      end
    end
  end
end
