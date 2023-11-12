defmodule GrpcReflectionTest do
  use ExUnit.Case
  doctest GrpcReflection

  test "greets the world" do
    assert GrpcReflection.hello() == :world
  end
end
