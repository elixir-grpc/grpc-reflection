defmodule GrpcReflection.Case.NoDescriptor.Roundtrip.DeprecatedFieldsTest do
  @moduledoc false

  # Handler echoes all four fields back so we can confirm that fields marked
  # deprecated: true in FieldOptions encode and decode identically to active fields.
  defmodule Handler do
    use GRPC.Server, service: NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Service

    alias NoDescriptor.DeprecatedFields.DeprecatedResponse

    def process(req, _stream) do
      %DeprecatedResponse{
        success: true,
        result: req.active_field,
        old_result: req.legacy_field
      }
    end
  end

  use GrpcCase,
    service: NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Service,
    handler: Handler

  describe "v1" do
    setup :stub_v1_server

    test "deprecated fields round-trip identically to active fields", ctx do
      response =
        GrpcReflection.TestClient.grpcurl_call(
          ctx,
          "deprecated_fields.DeprecatedFieldsService/Process",
          %{"activeField" => "active_value", "legacyField" => "legacy_value"}
        )

      assert response["success"] == true
      assert response["result"] == "active_value"
      assert response["oldResult"] == "legacy_value"
    end
  end
end
