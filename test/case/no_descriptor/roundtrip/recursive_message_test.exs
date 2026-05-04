defmodule GrpcReflection.Case.NoDescriptor.Roundtrip.RecursiveMessageTest do
  @moduledoc false

  # Handler that echoes the reply back inside the reply's own request field,
  # exercising embedded TYPE_MESSAGE encoding via the synthesized descriptor.
  # The lowercase :call method name is also what caught bug #1 (Macro.camelize).
  defmodule Handler do
    use GRPC.Server, service: NoDescriptor.RecursiveMessage.Service.Service

    alias NoDescriptor.RecursiveMessage.{Reply, Request}

    def call(req, _stream) do
      %Reply{request: %Request{reply: %Reply{request: req}}}
    end
  end

  use GrpcCase,
    service: NoDescriptor.RecursiveMessage.Service.Service,
    handler: Handler

  describe "v1" do
    setup :stub_v1_server

    test "roundtrip encodes and decodes embedded message fields correctly", ctx do
      response =
        GrpcReflection.TestClient.grpcurl_call(
          ctx,
          "recursive_message.Service/call",
          %{}
        )

      # The handler wraps the request two levels deep — confirm the nested structure
      # decoded correctly via the synthesized descriptor.
      assert is_map(response["request"])
      assert is_map(response["request"]["reply"])
      assert is_map(response["request"]["reply"]["request"])
    end
  end
end
