defmodule GrpcReflection.ServiceTest do
  @moduledoc false

  use ExUnit.Case

  setup do
    # clear state for empty setup and dynamic adding
    Application.put_env(:grpc_reflection, :services, [])
    {:ok, _pid} = GrpcReflection.Service.start_link()
    :ok
  end

  test "adding a service changes responses" do
    assert GrpcReflection.list_services() == []
    assert GrpcReflection.get_by_symbol("helloworld.Greeter") == {:error, "symbol not found"}

    assert GrpcReflection.get_by_filename("helloworld.Greeter.proto") ==
             {:error, "filename not found"}

    assert :ok == GrpcReflection.put_services([Helloworld.Greeter.Service])

    assert GrpcReflection.list_services() == ["helloworld.Greeter"]

    assert {:ok, %{file_descriptor_proto: proto}} =
             GrpcReflection.get_by_symbol("helloworld.Greeter")

    assert {:ok, %{file_descriptor_proto: ^proto}} =
             GrpcReflection.get_by_filename("helloworld.Greeter.proto")
  end

  describe "reflection state testing" do
    setup do
      GrpcReflection.put_services([
        Helloworld.Greeter.Service,
        Grpc.Reflection.V1.ServerReflection.Service,
        Grpc.Reflection.V1alpha.ServerReflection.Service
      ])
    end

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
