defmodule GrpcReflection.Service.BuilderTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.State
  alias GrpcReflection.Service.Builder

  test "supports all reflection types in proto3" do
    assert {:ok, tree} = Builder.build_reflection_tree([TestserviceV3.TestService.Service])
    assert %State{services: [TestserviceV3.TestService.Service]} = tree

    assert Map.keys(tree.files) == [
             "google.protobuf.Any.proto",
             "google.protobuf.StringValue.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV3.proto"
           ]

    assert Map.keys(tree.symbols) == [
             "google.protobuf.Any",
             "google.protobuf.StringValue",
             "google.protobuf.Timestamp",
             "testserviceV3.Enum",
             "testserviceV3.TestReply",
             "testserviceV3.TestRequest",
             "testserviceV3.TestRequest.GEntry",
             "testserviceV3.TestRequest.Payload",
             "testserviceV3.TestRequest.Payload.Location",
             "testserviceV3.TestRequest.Token",
             "testserviceV3.TestService",
             "testserviceV3.TestService.CallFunction"
           ]

    Enum.each(Map.values(tree.files), fn payload ->
      assert payload.syntax == "proto3"
    end)
  end

  test "supports all reflection types in proto2" do
    assert {:ok, tree} = Builder.build_reflection_tree([TestserviceV2.TestService.Service])
    assert %State{services: [TestserviceV2.TestService.Service]} = tree

    assert Map.keys(tree.files) == [
             "google.protobuf.Any.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV2.TestRequestExtension.proto",
             "testserviceV2.proto"
           ]

    assert Map.keys(tree.symbols) == [
             "google.protobuf.Any",
             "google.protobuf.Timestamp",
             "testserviceV2.Enum",
             "testserviceV2.TestReply",
             "testserviceV2.TestRequest",
             "testserviceV2.TestRequest.GEntry",
             "testserviceV2.TestService",
             "testserviceV2.TestService.CallFunction"
           ]

    assert %{
             "testserviceV2.TestRequest" => extensions
           } = tree.extensions

    # this is a bitstring that may contain whitespace characters
    assert extensions |> to_string() |> String.trim() == ""

    Enum.each(Map.values(tree.files), fn
      %{name: "google" <> _, syntax: syntax} -> assert syntax == "proto3"
      %{name: _, syntax: syntax} -> assert syntax == "proto2"
    end)
  end

  test "handles an empty service" do
    assert {:ok, tree} = Builder.build_reflection_tree([EmptyService.Service])
    assert %State{services: [EmptyService.Service]} = tree

    Enum.each(Map.values(tree.files), fn payload ->
      # empty services default to proto2
      assert payload.syntax == "proto2"
      assert payload.dependency == []
      assert payload.message_type == []
      assert payload.enum_type == []

      assert payload.service == [
               %Google.Protobuf.ServiceDescriptorProto{
                 name: "EmptyService",
                 method: [],
                 options: nil,
                 __unknown_fields__: []
               }
             ]
    end)
  end

  test "handles a service with a custom prefix" do
    assert {:ok, tree} = Builder.build_reflection_tree([HLW.TestService.Service])
    assert %State{services: [HLW.TestService.Service]} = tree

    names = Enum.map(Map.values(tree.files), & &1.name)

    assert names == [
             "google.protobuf.Any.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV2.TestRequestExtension.proto",
             "testserviceV2.proto"
           ]
  end

  test "handles a non-service module" do
    assert_raise UndefinedFunctionError, fn ->
      Builder.build_reflection_tree([Enum])
    end
  end

  # protobuf_generate wraps service descriptors into FileDescriptors
  # fake a service module here to test unwrapping logic
  defmodule WrappedService do
    def __meta__(:name), do: "WrappedService"
    defdelegate __rpc_calls__, to: EmptyService.Service

    def descriptor do
      %Google.Protobuf.FileDescriptorProto{service: [EmptyService.Service.descriptor()]}
    end
  end

  test "handles a protobuf_generate file descriptor" do
    assert {:ok, tree} = Builder.build_reflection_tree([WrappedService])
    assert %State{services: [WrappedService]} = tree
  end
end
