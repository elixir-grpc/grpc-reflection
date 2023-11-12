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
        {:file_containing_symbol, symbol} -> file_containing_symbol(symbol)
        {:file_by_filename, filename} -> file_by_filename(filename)
        other -> {:unexpected, "received inexpected reflection request: #{inspect(other)}"}
      end
      |> case do
        {:ok, message_response} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response: message_response
          }

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
      Enum.map(services(), fn service_mod ->
        %{name: service_mod.__meta__(:name)}
      end)

    {:ok, {:list_services_response, %{service: services}}}
  end

  defp file_containing_symbol(symbol) do
    case Enum.find(services(), fn service -> service.__meta__(:name) == symbol end) do
      nil -> {:error, :not_found}
      module -> {:ok, {:file_descriptor_response, build_descriptor(symbol, module)}}
    end
  end

  defp file_by_filename(filename) do
    filename
    |> String.split("-")
    |> then(fn [package, protoname] ->
      [
        package,
        protoname |> String.replace(".proto", "") |> upcase_first() |> module_from_string()
      ]
    end)
    |> IO.inspect()
    |> then(fn
      [_package, nil] ->
        {:error, :not_found}

      [package, module] ->
        payload =
          %Google.Protobuf.FileDescriptorProto{
            name: filename,
            package: package,
            message_type: [module.descriptor()]
          }
          |> Google.Protobuf.FileDescriptorProto.encode()

        {:ok,
         {:file_descriptor_response,
          %Grpc.Reflection.V1.FileDescriptorResponse{file_descriptor_proto: [payload]}}}
    end)
  end

  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

  defp build_descriptor(service_name, service_mod) do
    package = package_from_service_name(service_name)
    descriptor = service_mod.descriptor()

    dependencies =
      descriptor
      |> types_from_descriptor()
      |> Enum.map(fn name -> package <> "-" <> name <> ".proto" end)

    payload =
      %Google.Protobuf.FileDescriptorProto{
        name: package <> ".proto",
        package: package,
        service: [descriptor],
        # file dependencies, plug in pseudo names
        dependency: dependencies,
        public_dependency: 0..length(dependencies)
      }
      |> Google.Protobuf.FileDescriptorProto.encode()

    %Grpc.Reflection.V1.FileDescriptorResponse{file_descriptor_proto: [payload]}
  end

  defp services do
    (Application.get_env(:grpc_reflection, :services, []) ++
       [Grpc.Reflection.V1.ServerReflection.Service])
    |> Enum.uniq()
  end

  defp types_from_descriptor(%Google.Protobuf.ServiceDescriptorProto{} = descriptor) do
    descriptor.method
    |> Enum.flat_map(fn method ->
      [method.input_type, method.output_type]
    end)
    |> Enum.map(fn
      "." <> symbol -> symbol
      symbol -> symbol
    end)
  end

  defp module_from_string(module_name) do
    mod = String.to_existing_atom("Elixir." <> module_name)

    if function_exported?(mod, :descriptor, 0) do
      IO.puts("descriptor exists")
      mod
    else
      mod.descriptor() |> IO.inspect()
      IO.puts("descriptor doesnt exist")
      nil
    end
  rescue
    _ ->
      IO.puts("Rescued!!")
      nil
  end

  defp package_from_service_name(service_name) do
    service_name
    |> String.split(".")
    |> Enum.reverse()
    |> case do
      [_ | rest] -> rest
      _ -> [""]
    end
    |> Enum.reverse()
    |> Enum.join(".")
  end
end
