defmodule GrpcReflection.Test do
  @moduledoc false

  use ExUnit.Case

  setup do
    Application.put_env(:grpc_reflection, :services, [
      Helloworld.Greeter.Service,
      Grpc.Reflection.V1.ServerReflection.Service,
      Grpc.Reflection.V1alpha.ServerReflection.Service
    ])
  end

  describe "reflection state testing without running agent" do
    test "expected services are present" do
      assert GrpcReflection.list_services() == [
               "helloworld.Greeter",
               "grpc.reflection.v1.ServerReflection",
               "grpc.reflection.v1alpha.ServerReflection"
             ]
    end

    test "method files return service descriptors" do
      assert {:ok, %{file_descriptor_proto: proto}} =
               GrpcReflection.get_by_symbol("helloworld.Greeter")

      assert {:ok, %{file_descriptor_proto: ^proto}} =
               GrpcReflection.get_by_symbol("helloworld.Greeter.SayHello")
    end

    test "describing a type returns the type" do
      assert {:ok, %{file_descriptor_proto: proto}} =
               GrpcReflection.get_by_symbol("helloworld.HelloRequest")

      assert {:ok, %{file_descriptor_proto: ^proto}} =
               GrpcReflection.get_by_filename("helloworld.HelloRequest.proto")
    end

    test "type with leading period still resolves" do
      assert {:ok, %{file_descriptor_proto: proto}} =
               GrpcReflection.get_by_symbol(".helloworld.HelloRequest")

      assert {:ok, %{file_descriptor_proto: ^proto}} =
               GrpcReflection.get_by_filename("helloworld.HelloRequest.proto")
    end
  end
end
