defmodule GrpcReflection.Server.V1alpha do
  @moduledoc false

  alias Grpc.Reflection.V1alpha.ErrorResponse
  alias Grpc.Reflection.V1alpha.ServerReflectionResponse
  alias GRPC.Server

  require Logger

  def server_reflection_info(state_mod, request_stream, server) do
    Enum.map(request_stream, fn request ->
      Logger.info("Received v1alpha reflection request: " <> inspect(request.message_request))

      state_mod
      |> reflection_request(request.message_request)
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

  def reflection_request(state_mod, message_request) do
    case message_request do
      {:list_services, _} ->
        state_mod.list_services()
        |> Enum.map(fn name -> %{name: name} end)
        |> then(fn services ->
          {:ok, {:list_services_response, %{service: services}}}
        end)

      {:file_containing_symbol, symbol} ->
        with {:ok, description} <- state_mod.get_by_symbol(symbol) do
          {:ok,
           {:file_descriptor_response,
            struct(Grpc.Reflection.V1alpha.FileDescriptorResponse, description)}}
        end

      {:file_by_filename, filename} ->
        with {:ok, description} <- state_mod.get_by_filename(filename) do
          {:ok,
           {:file_descriptor_response,
            struct(Grpc.Reflection.V1alpha.FileDescriptorResponse, description)}}
        end

      # {:file_containing_extension} not supported yet
      other ->
        {:unexpected, "received inexpected reflection request: #{inspect(other)}"}
    end
  end
end
