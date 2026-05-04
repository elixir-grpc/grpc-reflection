defmodule GrpcReflection.Service.BuilderTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.Builder
  alias GrpcReflection.Service.State

  setup_all do
    Protobuf.load_extensions()
  end

  test "supports proto3 services" do
    assert {:ok, tree} = Builder.build_reflection_tree([ScalarTypes.ScalarService.Service])
    assert %State{services: [ScalarTypes.ScalarService.Service]} = tree

    assert Map.keys(tree.files) == [
             "scalar_types.ScalarReply.proto",
             "scalar_types.ScalarRequest.proto",
             "scalar_types.ScalarService.proto"
           ]

    assert Map.keys(tree.symbols) == [
             "scalar_types.ScalarReply",
             "scalar_types.ScalarRequest",
             "scalar_types.ScalarService",
             "scalar_types.ScalarService.ProcessScalars"
           ]

    Enum.each(Map.values(tree.files), fn payload ->
      assert payload.syntax == "proto3"
    end)
  end

  test "supports proto2 services" do
    assert {:ok, tree} = Builder.build_reflection_tree([Proto2Features.Proto2Service.Service])
    assert %State{services: [Proto2Features.Proto2Service.Service]} = tree

    Enum.each(Map.values(tree.files), fn
      %{name: "google" <> _, syntax: syntax} -> assert syntax == "proto3"
      %{name: _, syntax: syntax} -> assert syntax == "proto2"
    end)
  end

  test "proto2 services expose extension numbers" do
    assert {:ok, tree} = Builder.build_reflection_tree([Proto2Features.Proto2Service.Service])

    assert %{"proto2_features.Proto2Request" => _} = tree.extensions
  end

  test "handles an empty service" do
    assert {:ok, tree} = Builder.build_reflection_tree([EmptyService.EmptyService.Service])
    assert %State{services: [EmptyService.EmptyService.Service]} = tree

    Enum.each(Map.values(tree.files), fn payload ->
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

  test "handles a service with a custom module prefix" do
    assert {:ok, tree} =
             Builder.build_reflection_tree([CustomizedPrefix.PrefixService.Service])

    assert %State{services: [CustomizedPrefix.PrefixService.Service]} = tree

    names = tree.files |> Map.values() |> Enum.map(& &1.name) |> Enum.sort()

    assert names == [
             "custom_prefix.EchoRequest.proto",
             "custom_prefix.EchoResponse.proto",
             "custom_prefix.PrefixService.proto"
           ]
  end

  test "does not produce top-level enum files for nested enums with the same name" do
    assert {:ok, tree} =
             Builder.build_reflection_tree([NestedEnumConflict.ConflictService.Service])

    file_names = Map.keys(tree.files)

    refute "nestedEnumConflict.ListFoosRequest.SortOrder.proto" in file_names
    refute "nestedEnumConflict.ListBarsRequest.SortOrder.proto" in file_names

    assert "nestedEnumConflict.ListFoosRequest.proto" in file_names
    assert "nestedEnumConflict.ListBarsRequest.proto" in file_names

    foos_file = tree.files["nestedEnumConflict.ListFoosRequest.proto"]

    assert [%{name: "ListFoosRequest", enum_type: [%{name: "SortOrder"}]}] =
             foos_file.message_type

    bars_file = tree.files["nestedEnumConflict.ListBarsRequest.proto"]

    assert [%{name: "ListBarsRequest", enum_type: [%{name: "SortOrder"}]}] =
             bars_file.message_type
  end

  test "handles a non-service module" do
    assert {:error, "non-service module provided"} = Builder.build_reflection_tree([Enum])
  end

  # protobuf_generate wraps service descriptors into FileDescriptors
  # fake a service module here to test unwrapping logic
  defmodule WrappedService do
    def __meta__(:name), do: "WrappedService"
    defdelegate __rpc_calls__, to: EmptyService.EmptyService.Service

    def descriptor do
      %Google.Protobuf.FileDescriptorProto{
        service: [EmptyService.EmptyService.Service.descriptor()]
      }
    end
  end

  test "handles a protobuf_generate file descriptor" do
    assert {:ok, tree} = Builder.build_reflection_tree([WrappedService])
    assert %State{services: [WrappedService]} = tree
  end

  test "handles a recursive message structure" do
    assert {:ok, tree} = Builder.build_reflection_tree([RecursiveMessage.Service.Service])

    # Request and Reply form a cycle and are merged into one file
    file_names = tree.files |> Map.keys() |> Enum.sort()
    assert length(file_names) == 2
    assert "recursive_message.Service.proto" in file_names

    assert tree.symbols |> Map.keys() |> Enum.sort() == [
             "recursive_message.Reply",
             "recursive_message.Request",
             "recursive_message.Service",
             "recursive_message.Service.call"
           ]
  end
end
