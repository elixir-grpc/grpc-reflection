defmodule GrpcReflection.ServerTest do
  @moduledoc false

  use GrpcCase

  defmodule Service do
    use GrpcReflection.Server, version: :v1
  end

  test "adding a service changes responses" do
    assert Service.list_services() == []

    assert Service.get_filename_by_symbol("scalar_types.ScalarService") ==
             {:error, "symbol not found"}

    assert Service.get_by_filename("scalar_types.ScalarService.proto") ==
             {:error, "filename not found"}

    assert :ok == Service.put_services([ScalarTypes.ScalarService.Service])

    assert Service.list_services() == ["scalar_types.ScalarService"]

    assert {:ok, filename} =
             Service.get_filename_by_symbol("scalar_types.ScalarService")

    assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
             Service.get_by_filename(filename)
  end

  describe "reflection state testing" do
    setup do
      Service.put_services([
        ScalarTypes.ScalarService.Service,
        Grpc.Reflection.V1.ServerReflection.Service,
        Grpc.Reflection.V1alpha.ServerReflection.Service
      ])
    end

    test "expected services are present" do
      assert Service.list_services() == [
               "scalar_types.ScalarService",
               "grpc.reflection.v1.ServerReflection",
               "grpc.reflection.v1alpha.ServerReflection"
             ]
    end

    test "method files return service descriptors" do
      assert {:ok, filename} =
               Service.get_filename_by_symbol("scalar_types.ScalarService")

      assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
               Service.get_by_filename(filename)
    end

    test "describing a type returns the type" do
      assert {:ok, filename} =
               Service.get_filename_by_symbol("scalar_types.ScalarRequest")

      assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
               Service.get_by_filename(filename)
    end

    test "type with leading period still resolves" do
      assert {:ok, filename} =
               Service.get_filename_by_symbol(".scalar_types.ScalarRequest")

      assert {:ok, %Google.Protobuf.FileDescriptorProto{name: ^filename}} =
               Service.get_by_filename(filename)
    end
  end
end
