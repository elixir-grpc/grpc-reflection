defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.State
  alias GrpcReflection.Service.Builder.Util

  def build_reflection_tree(services) do
    with :ok <- Util.validate_services(services) do
      services
      |> process_services()
      |> process_references()
    end
  end

  defp process_references(%State{} = state) do
    # references is a growing set.  Processing references can add new references
    case State.get_missing_references(state) do
      [] ->
        {:ok, state}

      missing_refs ->
        missing_refs
        |> Enum.reduce(state, &State.merge(&2, process_reference(&1)))
        |> process_references()
    end
  end

  defp process_services(services) do
    Enum.reduce(services, State.new(services), fn service, state ->
      State.merge(state, process_service(service))
    end)
  end

  defp process_service(service) do
    descriptor = service.descriptor()
    service_name = service.__meta__(:name)
    referenced_types = Util.types_from_descriptor(descriptor)

    method_symbols =
      Enum.map(
        descriptor.method,
        fn method -> service_name <> "." <> method.name end
      )

    unencoded_payload = process_common(service_name, service, descriptor)
    payload = FileDescriptorProto.encode(unencoded_payload)
    response = %{file_descriptor_proto: [payload]}

    State.new()
    |> State.add_symbols(
      method_symbols
      |> Enum.reduce(%{}, fn name, acc -> Map.put(acc, name, response) end)
      |> Map.put(service_name, response)
    )
    |> State.add_files(%{(service_name <> ".proto") => response})
    |> State.add_references(referenced_types)
  end

  defp process_reference(symbol) do
    symbol
    |> Util.convert_symbol_to_module()
    |> then(fn mod ->
      descriptor = mod.descriptor()
      name = symbol

      referenced_types = Util.types_from_descriptor(descriptor)
      unencoded_payload = process_common(name, mod, descriptor)
      payload = FileDescriptorProto.encode(unencoded_payload)
      response = %{file_descriptor_proto: [payload]}

      root_symbols = %{symbol => response}
      root_files = %{(symbol <> ".proto") => response}

      extension_file = symbol <> "Extension.proto"

      {root_extensions, root_files} =
        process_extensions(mod, symbol, extension_file, descriptor, root_files)

      State.new()
      |> State.add_files(root_files)
      |> State.add_symbols(root_symbols)
      |> State.add_extensions(root_extensions)
      |> State.add_references(referenced_types)
    end)
  end

  # Processes extensions recursively for proto2, if any. Invoked only when extensions are present.
  defp process_extensions(mod, symbol, extension_file, descriptor, root_files) do
    case process_extensions(mod, symbol, extension_file, descriptor) do
      {:ok, {extension_numbers, extension_payload}} ->
        {
          %{symbol => extension_numbers},
          Map.put(root_files, extension_file, %{file_descriptor_proto: [extension_payload]})
        }

      {:ignore, _} ->
        {%{}, root_files}
    end
  end

  defp process_extensions(
         mod,
         symbol,
         extension_file,
         %Google.Protobuf.DescriptorProto{extension_range: extension_range} = descriptor
       )
       when extension_range != [] do
    unencoded_extension_payload = %Google.Protobuf.FileDescriptorProto{
      name: extension_file,
      package: Util.package_from_name(symbol),
      dependency: [symbol <> ".proto"],
      syntax: Util.get_syntax(mod)
    }

    {extension_numbers, extension_files} =
      Enum.unzip(
        for %Google.Protobuf.DescriptorProto.ExtensionRange{
              start: start_index,
              end: end_index
            } <- descriptor.extension_range,
            index <- start_index..end_index,
            {_, ext} <- List.wrap(Protobuf.Extension.get_extension_props_by_tag(mod, index)) do
          {index, Util.convert_to_field_descriptor(symbol, ext)}
        end
      )

    message_list =
      for ext <- extension_files, Util.is_message_descriptor?(ext) do
        ext.type_name
        |> Util.convert_symbol_to_module()
        |> then(& &1.descriptor())
      end

    unencoded_extension_payload = %{
      unencoded_extension_payload
      | extension: extension_files,
        message_type: message_list
    }

    {:ok, {extension_numbers, FileDescriptorProto.encode(unencoded_extension_payload)}}
  end

  defp process_extensions(_, _, _, _), do: {:ignore, {nil, nil}}

  defp process_common(name, module, descriptor) do
    package = Util.package_from_name(name)

    dependencies =
      descriptor
      |> Util.types_from_descriptor()
      |> Enum.map(fn name ->
        name <> ".proto"
      end)
      |> Enum.uniq()

    response_stub =
      %FileDescriptorProto{
        name: name <> ".proto",
        package: package,
        dependency: dependencies,
        syntax: Util.get_syntax(module)
      }

    case descriptor do
      %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
      %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
      %Google.Protobuf.EnumDescriptorProto{} -> %{response_stub | enum_type: [descriptor]}
    end
  end
end
