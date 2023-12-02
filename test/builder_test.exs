defmodule GrpcReflection.BuilderTest do
  @moduledoc false

  use ExUnit.Case

  test "supports all reflection types" do
    tree = GrpcReflection.Builder.build_reflection_tree([Testservice.TestService.Service])
    assert %GrpcReflection.Service{services: [Testservice.TestService.Service]} = tree
  end
end
