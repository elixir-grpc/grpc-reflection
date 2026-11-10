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

  # Hand-built modules for shapes protoc-gen-elixir never generates: they break the
  # naming convention the builder uses to find nested types.
  defmodule Fakes do
    alias Google.Protobuf.DescriptorProto
    alias Google.Protobuf.FieldDescriptorProto
    alias Google.Protobuf.MethodDescriptorProto
    alias Google.Protobuf.ServiceDescriptorProto

    def string_field(name, number),
      do: %FieldDescriptorProto{name: name, number: number, type: :TYPE_STRING}

    def message_field(name, number, type_name),
      do: %FieldDescriptorProto{
        name: name,
        number: number,
        type: :TYPE_MESSAGE,
        type_name: type_name
      }

    def message(name, fields, nested \\ []),
      do: %DescriptorProto{name: name, field: fields, nested_type: nested}

    def service(name, request, response) do
      %ServiceDescriptorProto{
        name: name,
        method: [%MethodDescriptorProto{name: "call", input_type: request, output_type: response}]
      }
    end
  end

  # Odd.Outer.Inner is declared as "odd.Outer.Inner", but its module is not named after it,
  # so it cannot be found by name. The field that refers to it hands over its module.
  defmodule Odd.External do
    use Protobuf, full_name: "odd.External", syntax: :proto3
    field(:value, 1, type: :string)
    def descriptor, do: Fakes.message("External", [Fakes.string_field("value", 1)])
  end

  defmodule Odd.Outer.Renamed do
    use Protobuf, full_name: "odd.Outer.Inner", syntax: :proto3
    field(:external, 1, type: Odd.External)

    def descriptor,
      do: Fakes.message("Inner", [Fakes.message_field("external", 1, ".odd.External")])
  end

  defmodule Odd.Outer do
    use Protobuf, full_name: "odd.Outer", syntax: :proto3

    alias GrpcReflection.Service.BuilderTest.Odd.Outer.Renamed

    field(:inner, 1, type: Odd.Outer.Renamed)

    def descriptor do
      Fakes.message(
        "Outer",
        [Fakes.message_field("inner", 1, ".odd.Outer.Inner")],
        [Renamed.descriptor()]
      )
    end
  end

  defmodule Odd.Service do
    use GRPC.Service, name: "odd.Service"
    rpc(:call, Odd.Outer, Odd.Outer)
    def descriptor, do: Fakes.service("Service", ".odd.Outer", ".odd.Outer")
  end

  # Orphan.Outer declares a nested type that has no module at all, that nothing refers to,
  # and that uses a type nothing else does.
  defmodule Orphan.External do
    use Protobuf, full_name: "orphan.External", syntax: :proto3
    field(:value, 1, type: :string)
    def descriptor, do: Fakes.message("External", [Fakes.string_field("value", 1)])
  end

  defmodule Orphan.Outer do
    use Protobuf, full_name: "orphan.Outer", syntax: :proto3
    field(:value, 1, type: :string)

    def descriptor do
      Fakes.message(
        "Outer",
        [Fakes.string_field("value", 1)],
        [
          Fakes.message(
            "Lost",
            [Fakes.message_field("external", 1, ".orphan.External")],
            [Fakes.message("Deeper", [Fakes.string_field("value", 1)])]
          ),
          # no module either, but it uses nothing that is missing
          Fakes.message("Harmless", [Fakes.string_field("value", 1)])
        ]
      )
    end
  end

  defmodule Orphan.Service do
    use GRPC.Service, name: "orphan.Service"
    rpc(:call, Orphan.Outer, Orphan.Outer)
    def descriptor, do: Fakes.service("Service", ".orphan.Outer", ".orphan.Outer")
  end

  # The descriptor says Ghost.Outer uses a type that its fields do not (anymore), so
  # nothing traces it.
  defmodule Ghost.Outer do
    use Protobuf, full_name: "ghost.Outer", syntax: :proto3
    field(:value, 1, type: :string)

    def descriptor do
      Fakes.message("Outer", [
        Fakes.string_field("value", 1),
        Fakes.message_field("ghost", 2, ".ghost.Missing")
      ])
    end
  end

  defmodule Ghost.Service do
    use GRPC.Service, name: "ghost.Service"
    rpc(:call, Ghost.Outer, Ghost.Outer)
    def descriptor, do: Fakes.service("Service", ".ghost.Outer", ".ghost.Outer")
  end

  # Modules from protoc-gen-elixir before it recorded `full_name`: only the module names and
  # the descriptors say that Legacy.Holder.Item is declared inside Legacy.Holder. The request
  # refers to the nested type before the message that encloses it.
  defmodule Legacy.Holder.Item do
    use Protobuf, syntax: :proto3
    field(:value, 1, type: :string)
    def descriptor, do: Fakes.message("Item", [Fakes.string_field("value", 1)])
  end

  defmodule Legacy.Holder do
    use Protobuf, syntax: :proto3

    alias GrpcReflection.Service.BuilderTest.Legacy.Holder.Item

    field(:name, 1, type: :string)

    def descriptor,
      do: Fakes.message("Holder", [Fakes.string_field("name", 1)], [Item.descriptor()])
  end

  defmodule Legacy.Request do
    use Protobuf, syntax: :proto3
    field(:item, 1, type: Legacy.Holder.Item)
    field(:holder, 2, type: Legacy.Holder)

    def descriptor,
      do:
        Fakes.message("Request", [
          Fakes.message_field("item", 1, ".legacy.Holder.Item"),
          Fakes.message_field("holder", 2, ".legacy.Holder")
        ])
  end

  defmodule Legacy.Service do
    use GRPC.Service, name: "legacy.Service"
    rpc(:call, Legacy.Request, Legacy.Request)
    def descriptor, do: Fakes.service("Service", ".legacy.Request", ".legacy.Request")
  end

  describe "a nested type in a module that does not record its full name" do
    import ExUnit.CaptureLog

    test "is filed under its enclosing message, even when referred to first" do
      log =
        capture_log(fn ->
          assert {:ok, tree} = Builder.build_reflection_tree([Legacy.Service])

          refute is_map_key(tree.files, "legacy.Holder.Item.proto")
          assert tree.symbols["legacy.Holder.Item"] == "legacy.Holder.proto"

          assert [%{name: "Holder", nested_type: [%{name: "Item"}]}] =
                   tree.files["legacy.Holder.proto"].message_type

          assert GrpcReflection.GraphCheck.violations(tree) == []
        end)

      assert log == ""
    end
  end

  describe "a nested type whose module cannot be found by name" do
    import ExUnit.CaptureLog

    test "is traced through the module that refers to it" do
      log =
        capture_log(fn ->
          assert {:ok, tree} = Builder.build_reflection_tree([Odd.Service])

          assert is_map_key(tree.files, "odd.External.proto")
          assert tree.files["odd.Outer.proto"].dependency == ["odd.External.proto"]
          assert GrpcReflection.GraphCheck.violations(tree) == []
        end)

      assert log == ""
    end
  end

  describe "a nested type that nothing refers to and cannot be traced" do
    import ExUnit.CaptureLog

    test "is left out, so the file can still be loaded" do
      capture_log(fn ->
        assert {:ok, tree} = Builder.build_reflection_tree([Orphan.Service])

        assert [%{name: "Outer", nested_type: [%{name: "Harmless"}]}] =
                 tree.files["orphan.Outer.proto"].message_type

        assert tree.files["orphan.Outer.proto"].dependency == []
        refute is_map_key(tree.symbols, "orphan.Outer.Lost")
        refute is_map_key(tree.symbols, "orphan.Outer.Lost.Deeper")
        assert tree.symbols["orphan.Outer.Harmless"] == "orphan.Outer.proto"
        assert GrpcReflection.GraphCheck.violations(tree) == []
      end)
    end

    test "says what was left out and why" do
      log = capture_log(fn -> Builder.build_reflection_tree([Orphan.Service]) end)

      assert log =~ "[warning]"
      assert log =~ "orphan.Outer.Lost"
      assert log =~ "orphan.External"
      refute log =~ "[error]"
    end

    test "keeps nested types that can be loaded" do
      capture_log(fn ->
        assert {:ok, tree} = Builder.build_reflection_tree([NestedCrossReference.Service.Service])

        assert tree.files["nested_cross_reference.Holder.proto"].message_type
               |> hd()
               |> Map.fetch!(:nested_type)
               |> Enum.map(& &1.name) == ["Item", "Unused"]
      end)
    end
  end

  describe "a dependency no file provides" do
    import ExUnit.CaptureLog

    test "is reported as an error naming both files" do
      log = capture_log(fn -> Builder.build_reflection_tree([Ghost.Service]) end)

      assert log =~ "[error]"
      assert log =~ "ghost.Outer.proto, but it depends on ghost.Missing.proto"
      assert log =~ "clients will not be able to load it"
    end

    test "still serves everything it could build" do
      capture_log(fn ->
        assert {:ok, tree} = Builder.build_reflection_tree([Ghost.Service])
        assert is_map_key(tree.files, "ghost.Outer.proto")
        assert is_map_key(tree.files, "ghost.Service.proto")
      end)
    end

    test "is never reported for valid services" do
      log =
        capture_log(fn ->
          Builder.build_reflection_tree([
            NestedCrossReference.Service.Service,
            NoDescriptor.Nested.NestedService.Service
          ])
        end)

      assert log == ""
    end
  end
end
