defmodule GrpcReflection.Server.V1Test do
  @moduledoc false

  use GrpcCase

  defmodule Service do
    use GrpcReflection.Server, version: :v1
  end

  setup do
    Service.put_services([Helloworld.Greeter.Service])
    :ok
  end

  describe "reflect/2 list_services" do
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
end
