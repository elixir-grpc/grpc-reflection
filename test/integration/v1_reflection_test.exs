defmodule GrpcReflection.V1ReflectionTest do
  @moduledoc false

  use GrpcCase
  use GrpcReflection.TestClient, version: :v1

  @moduletag capture_log: true

  test "unsupported call is rejected", ctx do
    message = {:file_containing_extension, %Grpc.Reflection.V1.ExtensionRequest{}}
    assert {:error, _} = run_request(message, ctx)
  end

  describe "symbol queries" do
    test "should reject unknown symbol", ctx do
      message = {:file_containing_symbol, "other.Rejecter"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should return not found for an invalid method", ctx do
      message = {:file_containing_symbol, "scalar_types.ScalarService.NoSuchMethod"}
      assert {:error, _} = run_request(message, ctx)
    end
  end

  describe "filename queries" do
    test "should reject an unrecognized filename", ctx do
      message = {:file_by_filename, "does.not.exist.proto"}
      assert {:error, _} = run_request(message, ctx)
    end
  end
end
