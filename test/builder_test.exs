defmodule GrpcReflection.BuilderTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.Agent
  alias GrpcReflection.Service.Builder

  test "supports all reflection types in proto3" do
    tree = Builder.build_reflection_tree([TestserviceV3.TestService.Service])
    assert %Agent{services: [TestserviceV3.TestService.Service]} = tree

    assert Map.keys(tree.files) == [
             "google.protobuf.Any.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV3.Enum.proto",
             "testserviceV3.TestReply.proto",
             "testserviceV3.TestRequest.GEntry.proto",
             "testserviceV3.TestRequest.proto",
             "testserviceV3.TestService.proto"
           ]

    assert Map.keys(tree.symbols) == [
             "google.protobuf.Any",
             "google.protobuf.Timestamp",
             "testserviceV3.Enum",
             "testserviceV3.TestReply",
             "testserviceV3.TestRequest",
             "testserviceV3.TestRequest.GEntry",
             "testserviceV3.TestService",
             "testserviceV3.TestService.CallFunction"
           ]
  end

  test "supports all reflection types in proto2" do
    tree = Builder.build_reflection_tree([TestserviceV2.TestService.Service])
    assert %Agent{services: [TestserviceV2.TestService.Service]} = tree

    assert Map.keys(tree.files) == [
             "google.protobuf.Any.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV2.Enum.proto",
             "testserviceV2.TestReply.proto",
             "testserviceV2.TestRequest.GEntry.proto",
             "testserviceV2.TestRequest.proto",
             "testserviceV2.TestService.proto"
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
  end
end
