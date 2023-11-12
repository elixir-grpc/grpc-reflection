defmodule GrpcReflection.V1.Server do
  use GRPC.Server, service: Grpc.Reflection.V1.ServerReflection.Service

  alias GRPC.Server
  alias Grpc.Reflection.V1.{ServerReflectionResponse, ErrorResponse}

  require Logger

  def server_reflection_info(request_stream, server) do
    Enum.map(request_stream, fn request ->
      Logger.info("Received v1 reflection request: " <> inspect(request.message_request))

      request.message_request
      |> GrpcReflection.ServerCommon.reflection_request()
      |> case do
        {:ok, message_response} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response: message_response
          }

        {:error, :not_found} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response:
              {:error_response,
               %ErrorResponse{
                 error_code: GRPC.Status.not_found(),
                 error_message: "Could not resolve"
               }}
          }

        {:unexpected, message} ->
          Logger.warning(message)

          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response:
              {:error_response,
               %ErrorResponse{
                 error_code: GRPC.Status.unimplemented(),
                 error_message: "Operation not supported"
               }}
          }
      end
      |> then(&Server.send_reply(server, &1))
    end)
  end
end
