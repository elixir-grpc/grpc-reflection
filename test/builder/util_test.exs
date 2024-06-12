defmodule GrpcReflection.Service.Builder.UtilTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.Builder.Util

  setup_all do
    Protobuf.load_extensions()
  end

  describe "common utils" do
    test "get package from module" do
      assert "testserviceV3" ==
               Util.get_package("testserviceV3.TestRequest")

      assert "testserviceV3" ==
               Util.get_package("testserviceV3.TestRequest.Payload.Location")

      assert "testserviceV3" ==
               Util.get_package("testserviceV3.TestService")
    end

    test "downcase_first" do
      assert "hello" == Util.downcase_first("Hello")
    end

    test "convert symbol to module succeed" do
      assert TestserviceV3.TestRequest ==
               Util.convert_symbol_to_module("testserviceV3.TestRequest")
    end

    test "convert symbol to module fail" do
      assert_raise ArgumentError, fn ->
        Util.convert_symbol_to_module("testservice.TestRequest.Payload.Location")
      end
    end
  end

  describe "utils for dealing with proto2 only" do
    test "convert %Google.Protobuf.FieldProps{} to %Google.Protobuf.FieldDescriptorProto{}" do
      extendee = TestserviceV2.TestRequest

      # test for a POD(aka Plain Old Data) type
      extension_number = 10

      assert {TestserviceV2.PbExtension, extension} =
               Protobuf.Extension.get_extension_props_by_tag(extendee, extension_number)

      assert %Google.Protobuf.FieldDescriptorProto{
               name: "data",
               extendee: ^extendee,
               number: ^extension_number,
               label: 1
             } = result = Util.convert_to_field_descriptor(extendee, extension)

      assert Google.Protobuf.FieldDescriptorProto.Type.mapping()[:TYPE_STRING] == result.type
      assert nil == result.type_name

      # test for a message type
      extension_number = 11

      assert {TestserviceV2.PbExtension, extension} =
               Protobuf.Extension.get_extension_props_by_tag(extendee, extension_number)

      assert %Google.Protobuf.FieldDescriptorProto{
               name: "location",
               extendee: ^extendee,
               number: ^extension_number,
               label: 1
             } = result = Util.convert_to_field_descriptor(extendee, extension)

      assert Google.Protobuf.FieldDescriptorProto.Type.mapping()[:TYPE_MESSAGE] == result.type
      assert "testserviceV2.Location" == result.type_name
    end
  end
end
