defmodule GrpcReflection.Server do
  use GRPC.Server, service: Grpc.Reflection.V1.ServerReflection.Service

  alias GRPC.Server
  alias Grpc.Reflection.V1.{ServerReflectionResponse, ErrorResponse}

  require Logger

  def server_reflection_info(request_stream, server) do
    Enum.map(request_stream, fn request ->
      request.message_request
      |> IO.inspect()
      |> case do
        {:list_services, _} -> list_services()
        {:file_containing_symbol, symbol} -> file_containing_symbol(symbol)
        {:file_by_filename, filename} -> file_by_filename(filename)
        # {:file_containing_extension} not supported yet
        other -> {:unexpected, "received inexpected reflection request: #{inspect(other)}"}
      end
      |> case do
        {:ok, message_response} ->
          %ServerReflectionResponse{
            valid_host: request.host,
            original_request: request,
            message_response: message_response
          }

        {:error, :not_found} ->
          %ServerReflectionResponse{
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
    # A symbol here could be one of 3 things:
    # 1 - the name of a service
    # 2 - a service method {service_name}.{method}
    # 3 - a type name
    #
    # We can check cases 1 and 3 directly, but case 2 is indirect

    maybe_service_mod = Enum.find(services(), fn service -> service.__meta__(:name) == symbol end)

    maybe_method =
      Enum.find(services(), fn service ->
        String.starts_with?(symbol, service.__meta__(:name) <> ".")
      end)

    maybe_module = module_from_string(symbol)

    cond do
      not is_nil(maybe_service_mod) -> build_response(symbol, maybe_service_mod.descriptor)
      not is_nil(maybe_method) -> build_response(symbol, maybe_method.descriptor)
      not is_nil(maybe_module) -> build_response(symbol, maybe_module)
      true -> {:error, :not_found}
    end

    # case Enum.find(services(), fn service -> service.__meta__(:name) == symbol end) do
    #   nil ->
    #     case module_from_string(symbol) do
    #       nil -> {:error, :not_found}
    #       descriptor -> build_response(symbol, descriptor)
    #     end

    #   service_module ->
    #     build_response(symbol, service_module.descriptor())
    # end

    # IO.inspect(symbol)
    # IO.inspect(services())

    # case Enum.find(services(), fn service -> service.__meta__(:name) == symbol end) do
    #   nil ->
    #     case Enum.find(services(), fn service ->
    #            IO.inspect(service.__meta__(:name))
    #            String.starts_with?(symbol, service.__meta__(:name))
    #          end) do
    #       nil ->
    #         symbol
    #         |> then(fn
    #           "." <> symbol -> symbol
    #           symbol -> symbol
    #         end)
    #         |> then(fn name -> package_from_name(name) <> "-" <> name <> ".proto" end)
    #         |> file_by_filename()

    #       module ->
    #         IO.puts("service_starts_with")
    #         {:ok, {:file_descriptor_response, build_descriptor(module.__meta__(:name), module)}}
    #     end

    #   module ->
    #     {:ok, {:file_descriptor_response, build_descriptor(symbol, module)}}
    # end
  end

  defp file_by_filename(filename) do
    # we build filenames to map to types, which should be module names
    filename
    |> String.split("-")
    |> then(fn
      [_pkg, protoname] -> module_from_string(protoname)
      [protoname] -> module_from_string(protoname)
    end)
    |> case do
      nil -> {:error, :not_found}
      descriptor -> build_response(filename, descriptor)
    end

    # filename
    # |> String.split("-")
    # |> then(fn [package, protoname] ->
    #   descriptor =
    #     protoname
    #     |> module_from_string()

    #   [package, descriptor]
    # end)
    # |> then(fn
    #   [_package, nil] ->
    #     {:error, :not_found}

    #   [package, descriptor] ->
    #     dependencies =
    #       descriptor
    #       |> types_from_descriptor()
    #       |> Enum.map(fn name -> package_from_name(name) <> "-" <> name <> ".proto" end)

    #     payload =
    #       %Google.Protobuf.FileDescriptorProto{
    #         name: filename,
    #         package: package,
    #         message_type: [descriptor],
    #         dependency: dependencies
    #       }
    #       |> Google.Protobuf.FileDescriptorProto.encode()

    #     {:ok,
    #      {:file_descriptor_response,
    #       %Grpc.Reflection.V1.FileDescriptorResponse{file_descriptor_proto: [payload]}}}
    # end)
  end

  defp build_response(name, descriptor) do
    # sanitize the name
    name =
      name
      |> String.split("-")
      |> then(fn
        [_, n] -> n
        [n] -> n
      end)
      |> String.split(".")
      |> Enum.reverse()
      |> then(fn
        ["proto" | rest] -> rest
        rest -> rest
      end)
      |> Enum.reverse()
      |> Enum.join(".")

    package = package_from_name(name)

    dependencies =
      descriptor
      |> types_from_descriptor()
      |> Enum.map(fn name ->
        package_from_name(name) <> "-" <> name <> ".proto"
      end)

    response_stub = %Google.Protobuf.FileDescriptorProto{
      name: package <> "-" <> name <> ".proto",
      package: package,
      dependency: dependencies
    }

    unencoded_payload =
      case descriptor do
        %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
        %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
      end

    payload = Google.Protobuf.FileDescriptorProto.encode(unencoded_payload)
    # %Grpc.Reflection.V1.FileDescriptorResponse{file_descriptor_proto: [payload]}

    {:ok,
     {:file_descriptor_response,
      %Grpc.Reflection.V1.FileDescriptorResponse{file_descriptor_proto: [payload]}}}
  end

  # defp build_descriptor(service_name, service_mod) do
  #   package = package_from_name(service_name)
  #   descriptor = service_mod.descriptor() |> IO.inspect()

  #   dependencies =
  #     descriptor
  #     |> types_from_descriptor()
  #     |> Enum.map(fn name ->
  #       package_from_name(name) <> "-" <> name <> ".proto"
  #     end)

  #   payload =
  #     %Google.Protobuf.FileDescriptorProto{
  #       name: package <> ".proto",
  #       package: package,
  #       service: [descriptor],
  #       # file dependencies, plug in pseudo names
  #       dependency: dependencies
  #     }
  #     |> Google.Protobuf.FileDescriptorProto.encode()

  #   %Grpc.Reflection.V1.FileDescriptorResponse{file_descriptor_proto: [payload]}
  # end

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
    |> Enum.reject(&is_atom/1)
    |> Enum.map(fn
      "." <> symbol -> symbol
      symbol -> symbol
    end)
  end

  defp types_from_descriptor(%Google.Protobuf.DescriptorProto{} = descriptor) do
    descriptor.field
    |> Enum.map(fn field ->
      field.type_name
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn
      "." <> symbol -> symbol
      symbol -> symbol
    end)
  end

  defp module_from_string(module_name) do
    module_name
    |> then(fn
      "." <> name -> name
      name -> name
    end)
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn
      ["proto", m | segments] -> [m | Enum.map(segments, &upcase_first/1)]
      [m | segments] -> [m | Enum.map(segments, &upcase_first/1)]
    end)
    |> Enum.reverse()
    |> Enum.join(".")
    |> then(fn name -> "Elixir." <> name end)
    |> String.to_existing_atom()
    |> then(fn mod -> mod.descriptor() end)
  rescue
    _ -> nil
  end

  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

  # these can be normal names or our pseudo file names
  defp package_from_name(service_name) do
    service_name
    |> String.split("-")
    |> case do
      [_, name] -> name
      [name] -> name
    end
    |> String.split(".")
    |> Enum.reverse()
    |> case do
      ["proto", _ | rest] -> rest
      [_ | rest] -> rest
      _ -> [""]
    end
    |> Enum.reverse()
    |> Enum.join(".")
  end
end
