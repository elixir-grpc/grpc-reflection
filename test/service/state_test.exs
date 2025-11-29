defmodule GrpcReflection.Service.StateTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.State

  describe "state collision detection" do
    test "service names ignore duplicates" do
      state1 = %State{services: ["service"]}
      state2 = %State{services: ["service"]}

      assert State.merge(state1, state2) == %State{services: ["service"]}
    end

    test "file collisions raise with different payloads" do
      state1 = %State{files: %{"filename" => "payload"}}
      state2 = %State{files: %{"filename" => "payload"}}

      assert State.merge(state1, state2) == %State{files: %{"filename" => "payload"}}

      state1 = %State{files: %{"filename" => "payload"}}
      state2 = %State{files: %{"filename" => "payload2"}}

      assert_raise RuntimeError,
                   ~r/Files Conflict detected: key filename present with multiple values/,
                   fn -> State.merge(state1, state2) end
    end

    test "symbol collisions raise with different payloads" do
      state1 = %State{symbols: %{"symbol_name" => "payload"}}
      state2 = %State{symbols: %{"symbol_name" => "payload"}}

      assert State.merge(state1, state2) == %State{symbols: %{"symbol_name" => "payload"}}

      state1 = %State{symbols: %{"symbol_name" => "payload"}}
      state2 = %State{symbols: %{"symbol_name" => "payload2"}}

      assert_raise RuntimeError,
                   ~r/Symbols Conflict detected: key symbol_name present with multiple values/,
                   fn -> State.merge(state1, state2) end
    end

    test "extension collisions raise with different payloads" do
      state1 = %State{extensions: %{"extension" => "payload"}}
      state2 = %State{extensions: %{"extension" => "payload"}}

      assert State.merge(state1, state2) == %State{extensions: %{"extension" => "payload"}}

      state1 = %State{extensions: %{"extension" => "payload"}}
      state2 = %State{extensions: %{"extension" => "payload2"}}

      assert_raise RuntimeError,
                   ~r/Extensions Conflict detected: key extension present with multiple values/,
                   fn -> State.merge(state1, state2) end
    end
  end

  describe "group_symbols_by_namespace" do
    setup do
      state_with_recursion = %State{
        services: ["Service1", "Service2"],
        files: %{
          "file1.proto" => %Google.Protobuf.FileDescriptorProto{
            name: "file1.proto",
            package: ".common.path",
            dependency: ["file2.proto"],
            service: ["A"],
            message_type: [%Google.Protobuf.DescriptorProto{name: "Symbol_a"}],
            syntax: "proto2"
          },
          "file2.proto" => %Google.Protobuf.FileDescriptorProto{
            name: "file2.proto",
            package: ".common.path",
            dependency: ["file1.proto"],
            service: ["B"],
            message_type: [%Google.Protobuf.DescriptorProto{name: "Symbol_b"}],
            syntax: "proto2"
          },
          "file3.proto" => %Google.Protobuf.FileDescriptorProto{
            name: "file3.proto",
            package: ".other.path",
            dependency: ["file1.proto", "file2.proto"],
            service: ["C"],
            message_type: [%Google.Protobuf.DescriptorProto{name: "Symbol_c"}],
            syntax: "proto2"
          }
        },
        symbols: %{
          "common.path.Symbol_a" => "file1.proto",
          "common.path.Symbol_b" => "file2.proto"
        }
      }

      %{
        state: State.group_symbols_by_namespace(state_with_recursion)
      }
    end

    test "should maintain all symbols", %{state: state} do
      assert Map.keys(state.symbols) == ["common.path.Symbol_a", "common.path.Symbol_b"]
    end

    test "should reduce and update files", %{state: state} do
      assert [combined_file, other_file] = Map.values(state.files)
      # combined file is present as we expect
      assert combined_file.dependency == []
      assert combined_file.name == "common.path.proto"
      # referencing file is updated as we expect
      assert other_file.dependency == ["common.path.proto"]
      assert other_file.name == "file3.proto"
    end

    test "should combine descriptors", %{state: state} do
      file = state.files["common.path.proto"]
      symbols = Enum.map(file.message_type, & &1.name)
      assert symbols == ["Symbol_a", "Symbol_b"]
      assert file.service == ["A", "B"]
    end
  end
end
