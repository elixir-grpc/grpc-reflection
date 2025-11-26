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
end
