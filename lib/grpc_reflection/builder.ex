defmodule GrpcReflection.Builder do
  @moduledoc false

  alias GrpcReflection.Service

  def build_reflection_tree(services) do
    with :ok <- validate_services(services),
         {%{files: _, symbols: _} = data, references} <- get_services_and_references(services) do
      references
      |> List.flatten()
      |> Enum.uniq()
      |> process_references(data)
    end
  end

  defp validate_services(services) do
    services
    |> Enum.reject(fn service_mod ->
      is_binary(service_mod.__meta__(:name)) and is_struct(service_mod.descriptor())
    end)
    |> then(fn
      [] -> :ok
      _ -> {:error, "non-service module provided"}
    end)
  rescue
    _ -> {:error, "non-service module provided"}
  end

  defp get_services_and_references(services) do
    Enum.reduce_while(services, {%Service{services: services}, []}, fn service, {acc, refs} ->
      with {:ok, %{files: files, symbols: symbols}, references} <- process_service(service) do
        {:cont,
         {%{acc | files: Map.merge(files, acc.files), symbols: Map.merge(symbols, acc.symbols)},
          [refs | references]}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp process_service(service) do
    descriptor = service.descriptor()
    service_name = service.__meta__(:name)
    referenced_types = types_from_descriptor(descriptor)

    method_symbols =
      Enum.map(
        descriptor.method,
        fn method -> service_name <> "." <> method.name end
      )

    unencoded_payload = process_common(service_name, descriptor)
    payload = Google.Protobuf.FileDescriptorProto.encode(unencoded_payload)
    response = %{file_descriptor_proto: [payload]}

    root_symbols =
      method_symbols
      |> Enum.reduce(%{}, fn name, acc -> Map.put(acc, name, response) end)
      |> Map.put(service_name, response)

    root_files = %{(service_name <> ".proto") => response}

    {:ok, %Service{files: root_files, symbols: root_symbols}, referenced_types}
  rescue
    _ -> {:error, "Couldn't process #{inspect(service)}"}
  end

  defp process_references([], data), do: data

  defp process_references([reference | rest], data) do
    if Map.has_key?(data.symbols, reference) do
      process_references(rest, data)
    else
      {%{files: f, symbols: s}, references} = process_reference(reference)
      data = %{data | files: Map.merge(data.files, f), symbols: Map.merge(data.symbols, s)}
      references = (rest ++ references) |> List.flatten() |> Enum.uniq()
      process_references(references, data)
    end
  end

  defp process_reference(symbol) do
    symbol
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn
      [m | segments] -> [m | Enum.map(segments, &upcase_first/1)]
    end)
    |> Enum.reverse()
    |> Enum.join(".")
    |> then(fn name -> "Elixir." <> name end)
    |> String.to_existing_atom()
    |> then(fn mod ->
      descriptor = mod.descriptor()
      name = symbol

      referenced_types = types_from_descriptor(descriptor)
      unencoded_payload = process_common(name, descriptor)
      payload = Google.Protobuf.FileDescriptorProto.encode(unencoded_payload)
      response = %{file_descriptor_proto: [payload]}

      root_symbols = %{symbol => response}
      root_files = %{(symbol <> ".proto") => response}

      {%Service{files: root_files, symbols: root_symbols}, referenced_types}
    end)
  end

  defp process_common(name, descriptor) do
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

    case descriptor do
      %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
      %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
    end
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

  defp package_from_name(service_name) do
    service_name
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn [_ | rest] -> rest end)
    |> Enum.reverse()
    |> Enum.join(".")
  end

  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest
end
