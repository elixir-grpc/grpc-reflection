defmodule GrpcReflection.Server.V1 do
  @moduledoc false

  alias Grpc.Reflection.V1.ErrorResponse
  alias Grpc.Reflection.V1.ServerReflectionResponse
  alias GRPC.Server

  require Logger

  def server_reflection_info(state_mod, request_stream, server) do
    Enum.map(request_stream, fn request ->
      Logger.debug("Received v1 reflection request: " <> inspect(request.message_request))

      response =
        state_mod
        |> reflect(request.message_request)
        |> handle_errors()

      message =
        %ServerReflectionResponse{
          valid_host: request.host,
          original_request: request,
          message_response: response
        }

      Server.send_reply(server, message)
    end)
  end

  defp handle_errors({:ok, payload}), do: payload

  defp handle_errors({:error, :unimplemented}) do
    {:error_response,
     %ErrorResponse{
       error_code: GRPC.Status.unimplemented(),
       error_message: "Operation not supported"
     }}
  end

  defp handle_errors({:error, reason}) do
    {:error_response,
     %ErrorResponse{
       error_code: GRPC.Status.not_found(),
       error_message: reason
     }}
  end

  def reflect(state_mod, {:list_services, _}) do
    state_mod.list_services()
    |> Enum.map(fn name -> %Grpc.Reflection.V1.ServiceResponse{name: name} end)
    |> then(fn services ->
      {:ok, {:list_services_response, %Grpc.Reflection.V1.ListServiceResponse{service: services}}}
    end)
  end

  def reflect(state_mod, {:file_containing_symbol, symbol}) do
    with {:ok, filename} <- state_mod.get_filename_by_symbol(symbol),
         {:ok, descriptor} <- state_mod.get_by_filename(filename) do
      {:ok,
       {:file_descriptor_response,
        %Grpc.Reflection.V1.FileDescriptorResponse{
          file_descriptor_proto: [Google.Protobuf.FileDescriptorProto.encode(descriptor)]
        }}}
    end
  end

  def reflect(state_mod, {:file_by_filename, filename}) do
    with {:ok, descriptor} <- state_mod.get_by_filename(filename) do
      {:ok,
       {:file_descriptor_response,
        %Grpc.Reflection.V1.FileDescriptorResponse{
          file_descriptor_proto: [Google.Protobuf.FileDescriptorProto.encode(descriptor)]
        }}}
    end
  end

  def reflect(
        state_mod,
        {:file_containing_extension,
         %{containing_type: containing_type, extension_number: _extension_number}}
      ) do
    with {:ok, descriptor} <- state_mod.get_by_extension(containing_type) do
      {:ok,
       {:file_descriptor_response,
        %Grpc.Reflection.V1.FileDescriptorResponse{
          file_descriptor_proto: [Google.Protobuf.FileDescriptorProto.encode(descriptor)]
        }}}
    end
  end

  def reflect(state_mod, {:all_extension_numbers_of_type, mod}) do
    with {:ok, extension_numbers} <- state_mod.get_extension_numbers_by_type(mod) do
      {:ok,
       {:all_extension_numbers_response,
        %Grpc.Reflection.V1.ExtensionNumberResponse{
          base_type_name: mod,
          extension_number: extension_numbers
        }}}
    end
  end

  def reflect(_state_mod, message_request) do
    Logger.warning("received unexpected reflection request: #{inspect(message_request)}")
    {:error, :unimplemented}
  end
end
