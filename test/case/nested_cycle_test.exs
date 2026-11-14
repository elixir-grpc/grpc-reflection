defmodule GrpcReflection.Case.NestedCycleTest do
  @moduledoc false

  use GrpcCase, service: NestedCycle.Service.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      # First -> Second.Inner -> First is a cycle between the files of First and Second,
      # so they have to be merged just like a cycle between top-level messages
      test "a cycle through a nested type is merged into one file", ctx do
        files =
          for symbol <- ["nested_cycle.First", "nested_cycle.Second.Inner"] do
            message = {:file_containing_symbol, symbol}

            assert {:ok, %Google.Protobuf.FileDescriptorProto{} = file} =
                     run_request(message, ctx)

            file
          end

        assert [file, file] = files
        refute file.name in file.dependency
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "nested_cycle.Service.call"} in ops
        assert {:type, ".nested_cycle.Second.Inner"} in ops
      end
    end
  end
end
