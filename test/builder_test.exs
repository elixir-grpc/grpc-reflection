defmodule GrpcReflection.BuilderTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.State
  alias GrpcReflection.Service.Builder

  test "supports all reflection types in proto3" do
    assert {:ok, tree} = Builder.build_reflection_tree([TestserviceV3.TestService.Service])
    assert %State{services: [TestserviceV3.TestService.Service]} = tree

    assert Map.keys(tree.files) == [
             "google.protobuf.Any.proto",
             "google.protobuf.StringValue.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV3.Enum.proto",
             "testserviceV3.TestReply.proto",
             "testserviceV3.TestRequest.GEntry.proto",
              "testserviceV3.TestRequest.Payload.Location.proto",
              "testserviceV3.TestRequest.Payload.proto",
              "testserviceV3.TestRequest.Token.proto",
             "testserviceV3.TestRequest.proto",
             "testserviceV3.TestService.proto"
           ]

    assert Map.keys(tree.symbols) == [
             "google.protobuf.Any",
             "google.protobuf.StringValue",
             "google.protobuf.Timestamp",
             "testserviceV3.Enum",
             "testserviceV3.TestReply",
             "testserviceV3.TestRequest",
             "testserviceV3.TestRequest.GEntry",
             "testserviceV3.TestRequest.Payload",
             "testserviceV3.TestRequest.Payload.Location",
             "testserviceV3.TestRequest.Token",
             "testserviceV3.TestService",
             "testserviceV3.TestService.CallFunction"
           ]

    (Map.values(tree.files) ++ Map.values(tree.symbols))
    |> Enum.flat_map(&Map.get(&1, :file_descriptor_proto))
    |> Enum.map(&Google.Protobuf.FileDescriptorProto.decode/1)
    |> Enum.each(fn payload ->
      assert payload.syntax == "proto3"
    end)
  end

  test "supports all reflection types in proto2" do
    assert {:ok, tree} = Builder.build_reflection_tree([TestserviceV2.TestService.Service])
    assert %State{services: [TestserviceV2.TestService.Service]} = tree

    assert Map.keys(tree.files) == [
             "google.protobuf.Any.proto",
             "google.protobuf.Timestamp.proto",
             "testserviceV2.Enum.proto",
             "testserviceV2.TestReply.proto",
             "testserviceV2.TestRequest.GEntry.proto",
             "testserviceV2.TestRequest.proto",
             "testserviceV2.TestRequestExtension.proto",
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

    assert tree.extensions == %{
             "testserviceV2.TestRequest" => [10, 11]
           }

    (Map.values(tree.files) ++ Map.values(tree.symbols))
    |> Enum.flat_map(&Map.get(&1, :file_descriptor_proto))
    |> Enum.map(&Google.Protobuf.FileDescriptorProto.decode/1)
    |> Enum.each(fn
      # the google types are proto3
      %{name: "google" <> _} = payload -> assert payload.syntax == "proto3"
      payload -> assert payload.syntax == "proto2"
    end)
  end

  test "handles an empty service" do
    assert {:ok, tree} = Builder.build_reflection_tree([TestserviceV2.EmptyService.Service])
    assert %State{services: [TestserviceV2.EmptyService.Service]} = tree

    (Map.values(tree.files) ++ Map.values(tree.symbols))
    |> Enum.flat_map(&Map.get(&1, :file_descriptor_proto))
    |> Enum.map(&Google.Protobuf.FileDescriptorProto.decode/1)
    |> Enum.each(fn payload ->
      # empty services default to proto2
      assert payload.syntax == "proto2"
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

  test "handles a non-service module" do
    assert_raise UndefinedFunctionError, fn ->
      Builder.build_reflection_tree([Enum])
    end
  end
end
