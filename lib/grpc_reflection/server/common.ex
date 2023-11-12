defmodule GrpcReflection.Server.Common do
  @moduledoc false
  require Logger

  @spec reflection_request(any()) ::
          {:error, :not_found}
          | {:ok, {:file_descriptor_response, map()} | {:list_services_response, map()}}
          | {:unexpected, <<_::64, _::_*8>>}
  def reflection_request(message_request) do
    case message_request do
      {:list_services, _} -> list_services()
      {:file_containing_symbol, symbol} -> file_containing_symbol(symbol)
      {:file_by_filename, filename} -> file_by_filename(filename)
      # {:file_containing_extension} not supported yet
      other -> {:unexpected, "received inexpected reflection request: #{inspect(other)}"}
    end
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

    maybe_service_mod = Enum.find(services(), fn service -> service.__meta__(:name) == symbol end)

    maybe_method =
      Enum.find(services(), fn service ->
        String.starts_with?(symbol, service.__meta__(:name) <> ".")
      end)

    maybe_module = module_from_string(symbol)

    cond do
      not is_nil(maybe_service_mod) -> build_response(symbol, maybe_service_mod.descriptor)
      not is_nil(maybe_method) -> check_methods(symbol, maybe_method)
      not is_nil(maybe_module) -> build_response(symbol, maybe_module)
      true -> {:error, :not_found}
    end
  end

  defp check_methods(symbol, service_mod) do
    # a symbol that starts_with a service name should be a service method
    # but it might be wrong, check the methods before returning success
    service_name = service_mod.__meta__(:name)
    descriptor = service_mod.descriptor

    descriptor.method
    |> Enum.find(fn method ->
      service_name <> "." <> method.name == symbol
    end)
    |> case do
      nil ->
        {:error, :not_found}

      _ ->
        IO.puts("method resolved")
        build_response(service_name, descriptor)
    end
  end

  defp file_by_filename(filename) do
    # we build filenames to map to types, which should be module names
    filename
    |> module_from_string()
    |> case do
      nil ->
        {:error, :not_found}

      descriptor ->
        IO.puts("filename #{filename} resolved")
        build_response(filename, descriptor)
    end
  end

  defp build_response(name, descriptor) do
    # sanitize the name
    name =
      name
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
        name <> ".proto"
      end)

    response_stub = %Google.Protobuf.FileDescriptorProto{
      name: name <> ".proto",
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

  defp services do
    Application.get_env(:grpc_reflection, :services, [])
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
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn [_ | rest] -> rest end)
    |> Enum.reverse()
    |> Enum.join(".")
  end
end
