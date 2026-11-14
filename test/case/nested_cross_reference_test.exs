defmodule GrpcReflection.Case.NestedCrossReferenceTest do
  @moduledoc false

  use GrpcCase, service: NestedCrossReference.Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      # a nested type is declared in the file of its outermost message, no matter which
      # message refers to it
      test "nested types resolve to the file of the message that declares them", ctx do
        for symbol <- [
              "nested_cross_reference.Holder",
              "nested_cross_reference.Holder.Item",
              "nested_cross_reference.Holder.Kind"
            ] do
          message = {:file_containing_symbol, symbol}
          assert {:ok, %Google.Protobuf.FileDescriptorProto{} = file} = run_request(message, ctx)
          assert file.name == "nested_cross_reference.Holder.proto"
          assert file.package == "nested_cross_reference"

          assert [%{name: "Holder", nested_type: nested, enum_type: enums}] = file.message_type
          assert "Item" in Enum.map(nested, & &1.name)
          assert "Kind" in Enum.map(enums, & &1.name)
        end
      end

      test "nested types that no field refers to are still found", ctx do
        for symbol <- [
              "nested_cross_reference.Holder.Unused",
              "nested_cross_reference.Holder.UnusedKind"
            ] do
          message = {:file_containing_symbol, symbol}

          assert {:ok, %Google.Protobuf.FileDescriptorProto{name: name}} =
                   run_request(message, ctx)

          assert name == "nested_cross_reference.Holder.proto"
        end
      end

      test "types used only by an unreferenced nested type are still served", ctx do
        message = {:file_by_filename, "nested_cross_reference.Holder.proto"}

        assert {:ok, %Google.Protobuf.FileDescriptorProto{dependency: deps}} =
                 run_request(message, ctx)

        assert "nested_cross_reference.Extra.proto" in deps

        message = {:file_by_filename, "nested_cross_reference.Extra.proto"}
        assert {:ok, %Google.Protobuf.FileDescriptorProto{}} = run_request(message, ctx)
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "nested_cross_reference.Service.call"} in ops
        assert {:call, "nested_cross_reference.Service.callItem"} in ops
        assert {:type, ".nested_cross_reference.Holder.Item"} in ops
      end
    end
  end
end
