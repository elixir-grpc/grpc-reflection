defmodule GrpcReflection.Case.NoDescriptor.Roundtrip.ScalarTypesTest do
  @moduledoc false

  # Handler that echoes a representative sample of scalar field values back in the reply.
  # Covers TYPE_INT32, TYPE_STRING, TYPE_BOOL, TYPE_DOUBLE, and TYPE_BYTES — enough to
  # confirm that field numbers and types in the synthesized descriptor are correct.
  defmodule Handler do
    use GRPC.Server, service: NoDescriptor.ScalarTypes.ScalarService.Service

    alias NoDescriptor.ScalarTypes.ScalarReply

    def process_scalars(req, _stream) do
      %ScalarReply{
        int32_list: [req.int32_field],
        string_list: [req.string_field],
        bool_list: [req.bool_field],
        double_list: [req.double_field],
        bytes_list: [req.bytes_field]
      }
    end
  end

  use GrpcCase, service: NoDescriptor.ScalarTypes.ScalarService.Service, handler: Handler

  describe "v1" do
    setup :stub_v1_server

    test "roundtrip encodes and decodes scalar field values correctly", ctx do
      response =
        GrpcReflection.TestClient.grpcurl_call(
          ctx,
          "scalar_types.ScalarService/ProcessScalars",
          %{
            "int32Field" => 42,
            "stringField" => "hello",
            "boolField" => true,
            "doubleField" => 3.14,
            "bytesField" => Base.encode64("bytes")
          }
        )

      assert response["int32List"] == [42]
      assert response["stringList"] == ["hello"]
      assert response["boolList"] == [true]
      assert_in_delta hd(response["doubleList"]), 3.14, 0.0001
    end
  end
end
