defmodule GrpcReflection.GraphCheckTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Google.Protobuf.DescriptorProto
  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.GraphCheck
  alias GrpcReflection.Service.State

  defp file(name, package, messages) do
    %FileDescriptorProto{
      name: name,
      package: package,
      message_type: Enum.map(messages, &%DescriptorProto{name: &1})
    }
  end

  defp state(files, symbols) do
    %State{files: Map.new(files, &{&1.name, &1}), symbols: Map.new(symbols)}
  end

  test "a state where every symbol is defined once is sound" do
    state =
      state(
        [file("pkg.A.proto", "pkg", ["A"]), file("pkg.B.proto", "pkg", ["B"])],
        [{"pkg.A", "pkg.A.proto"}, {"pkg.B", "pkg.B.proto"}]
      )

    assert GraphCheck.violations(state) == []
  end

  test "a symbol defined by two files is reported, naming both" do
    state =
      state(
        [file("pkg.A.proto", "pkg", ["A"]), file("pkg.B.proto", "pkg", ["B", "A"])],
        [{"pkg.A", "pkg.A.proto"}, {"pkg.B", "pkg.B.proto"}]
      )

    assert GraphCheck.violations(state) ==
             ["pkg.A is defined by more than one file: pkg.A.proto, pkg.B.proto"]
  end

  test "a nested type that is also a file of its own is reported" do
    outer = %{
      file("pkg.Outer.proto", "pkg", ["Outer"])
      | message_type: [
          %DescriptorProto{name: "Outer", nested_type: [%DescriptorProto{name: "Inner"}]}
        ]
    }

    state =
      state(
        [outer, file("pkg.Outer.Inner.proto", "pkg.Outer", ["Inner"])],
        [{"pkg.Outer", "pkg.Outer.proto"}, {"pkg.Outer.Inner", "pkg.Outer.proto"}]
      )

    assert GraphCheck.violations(state) ==
             [
               "pkg.Outer.Inner is defined by more than one file: " <>
                 "pkg.Outer.Inner.proto, pkg.Outer.proto"
             ]
  end
end
