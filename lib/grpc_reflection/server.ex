defmodule GrpcReflection.Server do
  use GRPC.Server, service: Grpc.Reflection.V1.ServerReflection.Service

  alias GRPC.Server
  alias Grpc.Reflection.V1.{ServerReflectionResponse, ErrorResponse}

  require Logger

  # @services Application.compile_env!(:grpc_reflection, :services)
  # IO.inspect(Application.get_env(:grpc_reflection, :services))

  def server_reflection_info(request_stream, server) do
    Enum.map(request_stream, fn request ->
      request.message_request
      |> case do
        {:list_services, _} -> list_services()
        # {:file_containing_symbol, symbol} -> file_containing_symbol(symbol)
        # {:file_by_filename, filename} -> file_by_filename(filename)
        other -> {:unexpected, "received inexpected reflection request: #{inspect(other)}"}
      end
      |> case do
        {:ok, message_response} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response: message_response
          }
          |> IO.inspect()

        {:not_found, message} ->
          Logger.warning(message)

          %ServerReflectionResponse{
            message_response:
              {:error_response,
               %ErrorResponse{error_code: GRPC.Status.not_found(), error_message: message}}
          }

        {:unexpected, message} ->
          Logger.warning(message)

          %ServerReflectionResponse{
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

  defp list_services do
    services =
      (Application.get_env(:grpc_reflection, :services, []) ++
         [Grpc.Reflection.V1.ServerReflection.Service])
      |> Enum.map(fn service_mod ->
        %{name: service_mod.__meta__(:name)}
      end)

    {:ok, {:list_services_response, %{service: services}}}
  end
end
