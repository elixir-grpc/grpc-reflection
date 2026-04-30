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

      test "should return extension numbers for an extendable type", ctx do
        message = {:all_extension_numbers_of_type, "proto2_features.Proto2Request"}
        assert {:ok, response} = run_request(message, ctx)
        assert response.base_type_name == "proto2_features.Proto2Request"
        assert response.extension_number == [100, 101, 102, 103]
      end

      test "should resolve the file containing a specific extension", ctx do
        extension_request_mod =
          case ctx.version do
            :v1 -> Grpc.Reflection.V1.ExtensionRequest
            :v1alpha -> Grpc.Reflection.V1alpha.ExtensionRequest
          end

        message =
          {:file_containing_extension,
           struct(extension_request_mod, %{
             containing_type: "proto2_features.Proto2Request",
             extension_number: 100
           })}

        assert {:ok, response} = run_request(message, ctx)
        assert response.package == "proto2_features"
        assert response.dependency == ["proto2_features.Proto2Request.proto"]

        assert [
                 %Google.Protobuf.FieldDescriptorProto{
                   name: "extended_field",
                   extendee: "proto2_features.Proto2Request",
                   number: 100,
                   label: :LABEL_OPTIONAL,
                   type: :TYPE_STRING,
                   type_name: nil
                 },
                 %Google.Protobuf.FieldDescriptorProto{
                   name: "extended_timestamp",
                   extendee: "proto2_features.Proto2Request",
                   number: 101,
                   label: :LABEL_OPTIONAL,
                   type: :TYPE_INT64,
                   type_name: nil
                 },
                 %Google.Protobuf.FieldDescriptorProto{
                   name: "extension_data",
                   extendee: "proto2_features.Proto2Request",
                   number: 102,
                   label: :LABEL_OPTIONAL,
                   type: :TYPE_MESSAGE,
                   type_name: "proto2Features.ExtensionData"
                 },
                 %Google.Protobuf.FieldDescriptorProto{
                   name: "timestamp_extension",
                   extendee: "proto2_features.Proto2Request",
                   number: 103,
                   label: :LABEL_OPTIONAL,
                   type: :TYPE_MESSAGE,
                   type_name: "google.protobuf.Timestamp"
                 }
               ] = response.extension
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
