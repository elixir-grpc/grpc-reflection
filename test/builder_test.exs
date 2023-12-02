defmodule GrpcReflection.BuilderTest do
  @moduledoc false

  use ExUnit.Case

  test "supports all reflection types in proto3" do
    tree = GrpcReflection.Builder.build_reflection_tree([TestserviceV3.TestService.Service])
    assert %GrpcReflection.Service{services: [TestserviceV3.TestService.Service]} = tree
  end

  test "supports all reflection types in proto2" do
    tree = GrpcReflection.Builder.build_reflection_tree([TestserviceV2.TestService.Service])
    assert %GrpcReflection.Service{services: [TestserviceV2.TestService.Service]} = tree
  end
end
