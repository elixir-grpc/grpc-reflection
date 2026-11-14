defmodule GrpcReflection.Case.NoDescriptor.ShortNamesTest do
  @moduledoc false

  use GrpcCase, service: NoDescriptor.ShortNames.Service.Service

  setup :stub_v1_server

  test "single letter and lowercase type names keep the package of their file", ctx do
    for symbol <- ["short_names.A", "short_names.B", "short_names.lower"] do
      message = {:file_containing_symbol, symbol}

      assert {:ok, %Google.Protobuf.FileDescriptorProto{package: "short_names"}} =
               run_request(message, ctx)
    end
  end

  test "reflection graph is traversable using grpcurl", ctx do
    ops = GrpcReflection.TestClient.grpcurl_service(ctx)

    assert {:call, "short_names.Service.call"} in ops
    assert {:type, ".short_names.lower"} in ops
  end
end
