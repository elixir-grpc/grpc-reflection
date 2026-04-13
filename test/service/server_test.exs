defmodule GrpcReflection.ServerTest do
  @moduledoc false

  use GrpcCase

  defmodule Service do
    use GrpcReflection.Server, version: :v1
  end

  test "adding a service changes responses" do
    assert Service.list_services() == []

    assert Service.get_filename_by_symbol("helloworld.Greeter") ==
             {:error, "symbol not found"}

    assert Service.get_by_filename("helloworld.Greeter.proto") ==
             {:error, "filename not found"}

    assert :ok == Service.put_services([Helloworld.Greeter.Service])

    assert Service.list_services() == ["helloworld.Greeter"]

    assert {:ok, filename} =
             Service.get_filename_by_symbol("helloworld.Greeter")

    assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
             Service.get_by_filename(filename)
  end

  describe "reflect/2 list_services" do
    setup do
      Service.put_services([Helloworld.Greeter.Service])
      :ok
    end

    test "returns a ListServiceResponse struct, not a plain map" do
      assert {:ok, {:list_services_response, response}} =
               GrpcReflection.Server.V1.reflect(Service, {:list_services, ""})

      assert %Grpc.Reflection.V1.ListServiceResponse{} = response,
             "expected a %Grpc.Reflection.V1.ListServiceResponse{} struct, got: #{inspect(response)}"
    end

    test "service entries are ServiceResponse structs, not plain maps" do
      assert {:ok,
              {:list_services_response,
               %Grpc.Reflection.V1.ListServiceResponse{service: services}}} =
               GrpcReflection.Server.V1.reflect(Service, {:list_services, ""})

      assert [%Grpc.Reflection.V1.ServiceResponse{name: "helloworld.Greeter"}] = services,
             "expected a list of %Grpc.Reflection.V1.ServiceResponse{} structs, got: #{inspect(services)}"
    end
  end

  describe "reflection state testing" do
    setup do
      Service.put_services([
        Helloworld.Greeter.Service,
        Grpc.Reflection.V1.ServerReflection.Service,
        Grpc.Reflection.V1alpha.ServerReflection.Service
      ])
    end

    test "expected services are present" do
      assert Service.list_services() == [
               "helloworld.Greeter",
               "grpc.reflection.v1.ServerReflection",
               "grpc.reflection.v1alpha.ServerReflection"
             ]
    end

    test "method files return service descriptors" do
      assert {:ok, filename} =
               Service.get_filename_by_symbol("helloworld.Greeter")

      assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
               Service.get_by_filename(filename)
    end

    test "describing a type returns the type" do
      assert {:ok, filename} =
               Service.get_filename_by_symbol("helloworld.HelloRequest")

      assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
               Service.get_by_filename(filename)
    end

    test "type with leading period still resolves" do
      assert {:ok, filename} =
               Service.get_filename_by_symbol(".helloworld.HelloRequest")

      assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
               Service.get_by_filename(filename)
    end
  end
end
