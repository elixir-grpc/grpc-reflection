defmodule GrpcReflection.Server.V1 do
  use GRPC.Server, service: Grpc.Reflection.V1.ServerReflection.Service

  alias GRPC.Server
  alias Grpc.Reflection.V1.{ServerReflectionResponse, ErrorResponse}

  require Logger

  def server_reflection_info(request_stream, server) do
    Enum.map(request_stream, fn request ->
      Logger.info("Received v1 reflection request: " <> inspect(request.message_request))

      request.message_request
      |> reflection_request()
      |> case do
        {:ok, message_response} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response: message_response
          }

        {:error, reason} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response:
              {:error_response,
               %ErrorResponse{
                 error_code: GRPC.Status.not_found(),
                 error_message: reason
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

  def reflection_request(message_request) do
    case message_request do
      {:list_services, _} ->
        GrpcReflection.list_services()
        |> Enum.map(fn name -> %{name: name} end)
        |> then(fn services ->
          {:ok, {:list_services_response, %{service: services}}}
        end)

      {:file_containing_symbol, symbol} ->
        with {:ok, description} <- GrpcReflection.get_by_symbol(symbol) do
          {:ok,
           {:file_descriptor_response,
            struct(Grpc.Reflection.V1.FileDescriptorResponse, description)}}
        end

      {:file_by_filename, filename} ->
        with {:ok, description} <- GrpcReflection.get_by_filename(filename) do
          {:ok,
           {:file_descriptor_response,
            struct(Grpc.Reflection.V1.FileDescriptorResponse, description)}}
        end

      # {:file_containing_extension} not supported yet
      other ->
        {:unexpected, "received inexpected reflection request: #{inspect(other)}"}
    end
  end
end
