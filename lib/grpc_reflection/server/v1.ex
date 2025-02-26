defmodule GrpcReflection.Server.V1 do
  @moduledoc false

  alias Grpc.Reflection.V1.ErrorResponse
  alias Grpc.Reflection.V1.ServerReflectionResponse
  alias GRPC.Server

  require Logger

  def server_reflection_info(state_mod, request_stream, server) do
    Enum.map(request_stream, fn request ->
      Logger.info("Received v1 reflection request: " <> inspect(request.message_request))

      response =
        state_mod
        |> GrpcReflection.Server.Process.reflect(request.message_request)
        |> build_response()

      message =
        struct(ServerReflectionResponse,
          valid_host: request.host,
          original_request: request,
          message_response: response
        )

      Server.send_reply(server, message)
    end)
  end

  defp build_response({:ok, {:file_descriptor_response, description}}) do
    encoded = struct(Grpc.Reflection.V1.FileDescriptorResponse, description)
    {:file_descriptor_response, encoded}
  end

  defp build_response({:ok, {:all_extension_numbers_response, body}}) do
    encoded =
      struct(
        Grpc.Reflection.V1.ExtensionNumberResponse,
        body
      )

    {:all_extension_numbers_response, encoded}
  end

  defp build_response({:ok, {:list_services_response, %{service: services}}}) do
    {:list_services_response, %{service: services}}
  end

  defp build_response({:error, :unimplemented}) do
    {:error_response,
     %ErrorResponse{
       error_code: GRPC.Status.unimplemented(),
       error_message: "Operation not supported"
     }}
  end

  defp build_response({:error, reason}) do
    {:error_response,
     %ErrorResponse{
       error_code: GRPC.Status.not_found(),
       error_message: reason
     }}
  end
end
