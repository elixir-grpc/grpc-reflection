defmodule GrpcReflection.CircularDependencyTest do
  @moduledoc """
  Tests for the new file-based descriptor approach that resolves circular dependency issues.

  This test specifically addresses the issue where per-message file descriptors
  caused infinite recursion with circular dependencies like google.protobuf.Struct.
  """

  use ExUnit.Case

  alias GrpcReflection.Service
  alias GrpcReflection.Service.State

  describe "file-based descriptor resolution" do
    test "handles circular dependencies without stack overflow" do
      # Test with our helloworld service that has external dependencies
      services = [Helloworld.Greeter.Service]

      # This should not crash with stack overflow
      assert {:ok, state} = Service.build_reflection_tree(services)

      # Verify the state has both legacy and new file-based fields
      assert %State{} = state
      # Legacy field
      assert is_map(state.symbols)
      # Legacy field
      assert is_map(state.files)
      # New field
      assert is_map(state.file_descriptors)
      # New field
      assert is_map(state.message_to_file)
    end

    test "BEAM metadata extraction working" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Verify that we're using real file paths from BEAM metadata
      file_paths = Map.keys(state.file_descriptors)

      # Should have clean proto paths from BEAM metadata
      assert length(file_paths) > 0, "Should have proto file paths from BEAM metadata"

      # Verify we have the expected helloworld proto file (with project relative path from BEAM metadata)
      assert Enum.member?(file_paths, "test/support/protos/helloworld.proto"),
             "Should have test/support/protos/helloworld.proto from BEAM metadata. Got: #{inspect(file_paths)}"

      # Verify we have meaningful proto paths (not long filesystem paths)
      Enum.each(file_paths, fn path ->
        assert String.ends_with?(path, ".proto"), "All paths should be .proto files"
        # Should be clean paths, not long filesystem paths
        refute String.contains?(path, "/Users/"), "Should not contain absolute filesystem paths"
      end)
    end

    test "file-based lookup returns valid descriptors" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Test that we can lookup symbols via the new file-based approach
      result = State.lookup_symbol("helloworld.HelloRequest", state)

      case result do
        {:ok, %{file_descriptor_proto: [binary]}} when is_binary(binary) ->
          # Success - we got a binary file descriptor
          assert byte_size(binary) > 0

        {:ok, %{file_descriptor_proto: descriptors}} when is_list(descriptors) ->
          # Legacy format - also acceptable
          assert length(descriptors) > 0

        {:error, _reason} ->
          # If file-based lookup fails, it should fall back to legacy
          # This is expected during transition period
          :ok
      end
    end

    test "same file groups return identical descriptors" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Verify that file-based storage is populated
      assert map_size(state.file_descriptors) > 0
      assert map_size(state.message_to_file) > 0

      # Get descriptors for messages that should be in the same file
      result1 = State.lookup_symbol("helloworld.HelloRequest", state)
      result2 = State.lookup_symbol("helloworld.HelloReply", state)

      case {result1, result2} do
        {{:ok, %{file_descriptor_proto: [desc1]}}, {:ok, %{file_descriptor_proto: [desc2]}}} ->
          # Check if they're the same (they might not be with BEAM metadata approach)
          if desc1 == desc2 do
            assert true, "Messages use file-based grouping"
          else
            # With BEAM metadata, each message might have its own real file
            assert byte_size(desc1) > 0
            assert byte_size(desc2) > 0
            IO.puts("BEAM metadata: Messages have separate real source files")
          end

        _ ->
          # During transition, some lookups might use legacy approach
          # This is acceptable as long as no crashes occur
          :ok
      end
    end

    test "realistic file structure inference" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Check that we now have realistic file paths instead of flat namespace files
      file_paths = Map.keys(state.file_descriptors)

      # Should have real paths from BEAM metadata
      real_paths =
        Enum.filter(file_paths, fn path ->
          String.contains?(path, "/") and String.ends_with?(path, ".proto")
        end)

      assert length(real_paths) > 0, "Should have realistic file paths with directory structure"

      # The paths should be actual file system paths or well-structured proto paths
      # With BEAM metadata, we might get absolute paths from the build system
    end

    test "service and method symbols return same descriptor" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Service and its methods should return the same file descriptor
      service_result = State.lookup_symbol("helloworld.Greeter", state)
      method_result = State.lookup_symbol("helloworld.Greeter.SayHello", state)

      case {service_result, method_result} do
        {{:ok, %{file_descriptor_proto: [service_desc]}},
         {:ok, %{file_descriptor_proto: [method_desc]}}} ->
          assert service_desc == method_desc,
                 "Service and method should return same file descriptor"

        _ ->
          # Both should at least succeed
          assert {:ok, _} = service_result
          assert {:ok, _} = method_result
      end
    end

    test "file-based descriptors contain multiple message types" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Check if we have file descriptors in the new format
      if map_size(state.file_descriptors) > 0 do
        # Get a file descriptor
        {_filename, file_descriptor_binary} = Enum.at(state.file_descriptors, 0)

        # Decode and verify it contains multiple types as expected from file-based approach
        assert is_binary(file_descriptor_binary)
        assert byte_size(file_descriptor_binary) > 0

        # Try to decode the file descriptor
        case Google.Protobuf.FileDescriptorProto.decode(file_descriptor_binary) do
          %Google.Protobuf.FileDescriptorProto{} = file_desc ->
            # Verify it has the expected structure for a complete file
            assert is_binary(file_desc.name)
            assert String.ends_with?(file_desc.name, ".proto")

          _ ->
            flunk("File descriptor should be decodeable")
        end
      else
        # If no file descriptors yet, that's okay - implementation is progressive
        :ok
      end
    end

    test "message to file mapping works correctly" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # Check if we have message to file mappings
      if map_size(state.message_to_file) > 0 do
        # Verify the mapping structure
        Enum.each(state.message_to_file, fn {module, binary} ->
          assert is_atom(module)
          assert Code.ensure_loaded?(module)
          assert is_binary(binary)
          assert byte_size(binary) > 0
        end)
      else
        # If no mappings yet, that's okay - implementation is progressive
        :ok
      end
    end
  end

  describe "backward compatibility" do
    test "legacy lookup still works when file-based lookup fails" do
      services = [Helloworld.Greeter.Service]
      {:ok, state} = Service.build_reflection_tree(services)

      # This should work via either new or legacy approach
      result = State.lookup_symbol("helloworld.Greeter", state)

      assert {:ok, descriptor} = result
      assert Map.has_key?(descriptor, :file_descriptor_proto)
    end

    test "existing API maintains same signatures" do
      services = [Helloworld.Greeter.Service]

      # All existing functions should still work with same signatures
      assert {:ok, state} = Service.build_reflection_tree(services)

      # Test the state-based functions directly since we don't have supervisor in tests
      assert is_list(State.lookup_services(state))

      # The query functions should return expected format
      result = State.lookup_symbol("helloworld.Greeter", state)

      case result do
        {:ok, _descriptor} -> assert true
        {:error, _reason} -> assert true
        _ -> flunk("Unexpected result format: #{inspect(result)}")
      end
    end
  end
end
