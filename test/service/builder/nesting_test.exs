defmodule GrpcReflection.Service.Builder.NestingTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias GrpcReflection.Service.Builder.Nesting

  # Modules that look nested by name but do not agree with their `full_name`s, or have none.
  defmodule Stranger do
    use Protobuf, full_name: "elsewhere.Stranger", syntax: :proto3
    field(:value, 1, type: :string)
  end

  defmodule Stranger.Child do
    use Protobuf, full_name: "pkg.Child", syntax: :proto3
    field(:value, 1, type: :string)
  end

  defmodule Anonymous do
    use Protobuf, syntax: :proto3
    field(:value, 1, type: :string)
  end

  defmodule Anonymous.Child do
    use Protobuf, syntax: :proto3
    field(:value, 1, type: :string)
  end

  describe "parent/2" do
    test "finds the message enclosing a nested message" do
      assert {"nested.OuterMessage.MiddleMessage", Nested.OuterMessage.MiddleMessage} =
               Nesting.parent(
                 "nested.OuterMessage.MiddleMessage.InnerMessage",
                 Nested.OuterMessage.MiddleMessage.InnerMessage
               )
    end

    test "finds the message enclosing a nested enum" do
      assert {"nested_cross_reference.Holder", NestedCrossReference.Holder} =
               Nesting.parent(
                 "nested_cross_reference.Holder.Kind",
                 NestedCrossReference.Holder.Kind
               )
    end

    test "a top-level type has no parent" do
      assert Nesting.parent("nested.OuterMessage", Nested.OuterMessage) == nil
    end

    test "a module only nested by name is not nested when full_names disagree" do
      assert Nesting.parent("pkg.Child", Stranger.Child) == nil
    end

    test "modules without a full_name are treated as top-level" do
      assert Nesting.parent("pkg.Child", Anonymous.Child) == nil
    end
  end

  describe "top_level/2" do
    test "walks up to the outermost message" do
      assert {"nested.OuterMessage", Nested.OuterMessage} =
               Nesting.top_level(
                 "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
                 Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage
               )
    end

    test "a top-level type is its own outermost message" do
      assert {"nested.OuterMessage", Nested.OuterMessage} =
               Nesting.top_level("nested.OuterMessage", Nested.OuterMessage)
    end

    test "does not use type name capitalization" do
      assert {"short_names.lower", ShortNames.Lower} =
               Nesting.top_level("short_names.lower", ShortNames.Lower)
    end
  end

  describe "child_module/2" do
    test "finds a declared type by its proto name" do
      assert {:ok, NestedCrossReference.Holder.Item} =
               Nesting.child_module(NestedCrossReference.Holder, "Item")
    end

    test "is :error when there is no such module" do
      assert Nesting.child_module(NestedCrossReference.Holder, "Missing") == :error
    end

    test "is :error when the module found does not carry the expected full_name" do
      assert Nesting.child_module(Stranger, "Child") == :error
    end
  end

  describe "index/1" do
    test "groups the reachable nested types under their enclosing message" do
      index = Nesting.index([NoDescriptor.NestedCrossReference.Service.Service])

      assert index[NoDescriptor.NestedCrossReference.Holder] ==
               [
                 NoDescriptor.NestedCrossReference.Holder.Item,
                 NoDescriptor.NestedCrossReference.Holder.Kind
               ]

      assert index[NoDescriptor.NestedCrossReference.Request] ==
               [NoDescriptor.NestedCrossReference.Request.ItemsEntry]
    end

    test "leaves out nested types nothing reaches" do
      index = Nesting.index([NoDescriptor.NestedCrossReference.Service.Service])

      refute NoDescriptor.NestedCrossReference.Holder.Unused in index[
               NoDescriptor.NestedCrossReference.Holder
             ]
    end

    test "includes every level of nesting" do
      index = Nesting.index([NoDescriptor.Nested.NestedService.Service])

      assert NoDescriptor.Nested.OuterMessage.MiddleMessage in index[
               NoDescriptor.Nested.OuterMessage
             ]

      assert NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage in index[
               NoDescriptor.Nested.OuterMessage.MiddleMessage
             ]
    end

    test "is the same whichever service is listed first" do
      services = [
        NoDescriptor.NestedCrossReference.Service.Service,
        NoDescriptor.Nested.NestedService.Service
      ]

      assert Nesting.index(services) == Nesting.index(Enum.reverse(services))
    end
  end
end
