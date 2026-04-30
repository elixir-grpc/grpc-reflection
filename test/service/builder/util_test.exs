defmodule GrpcReflection.Service.Builder.UtilTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.Builder.Util

  setup_all do
    Protobuf.load_extensions()
  end

  describe "common utils" do
    test "get package from module" do
      assert "scalar_types" ==
               Util.get_package("scalar_types.ScalarRequest")

      assert "scalar_types" ==
               Util.get_package("scalar_types.ScalarService")

      assert "grpc.reflection.v1alpha" ==
               Util.get_package("grpc.reflection.v1alpha.FileDescriptorResponse")
    end

    test "downcase_first" do
      assert "hello" == Util.downcase_first("Hello")
    end

    test "get all nested types" do
      assert [
               "nested.OuterMessage.NestedMapEntry",
               "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
               "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
               "nested.OuterMessage.MiddleMessage.InnerMessage",
               "nested.OuterMessage.MiddleMessage"
             ] ==
               Util.get_nested_types(
                 "nested.OuterMessage",
                 Nested.OuterMessage.descriptor()
               )
    end
  end

  describe "utils for dealing with proto2 only" do
    test "convert %Google.Protobuf.FieldProps{} to %Google.Protobuf.FieldDescriptorProto{}" do
      extendee = Proto2Features.Proto2Request

      # test for a plain scalar type
      extension_number = 100

      assert {Proto2Features.PbExtension, extension} =
               Protobuf.Extension.get_extension_props_by_tag(extendee, extension_number)

      assert %Google.Protobuf.FieldDescriptorProto{
               name: "extended_field",
               extendee: ^extendee,
               number: ^extension_number,
               label: 1
             } = result = Util.convert_to_field_descriptor(extendee, extension)

      assert Google.Protobuf.FieldDescriptorProto.Type.mapping()[:TYPE_STRING] == result.type
      assert nil == result.type_name

      # test for a message type
      extension_number = 102

      assert {Proto2Features.PbExtension, extension} =
               Protobuf.Extension.get_extension_props_by_tag(extendee, extension_number)

      assert %Google.Protobuf.FieldDescriptorProto{
               name: "extension_data",
               extendee: ^extendee,
               number: ^extension_number,
               label: 1
             } = result = Util.convert_to_field_descriptor(extendee, extension)

      assert Google.Protobuf.FieldDescriptorProto.Type.mapping()[:TYPE_MESSAGE] == result.type
      assert "proto2Features.ExtensionData" == result.type_name
    end
  end
end
