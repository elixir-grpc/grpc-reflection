defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.State
  alias GrpcReflection.Service.Builder.Util

  @type_message Map.fetch!(Google.Protobuf.FieldDescriptorProto.Type.mapping(), :TYPE_MESSAGE)

  def build_reflection_tree(services) do
    with :ok <- validate_services(services),
         {%{files: _, symbols: _} = data, references} <- get_services_and_references(services) do
      references
      |> List.flatten()
      |> Enum.uniq()
      |> process_references(data)
      |> then(&{:ok, &1})
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
    Enum.reduce_while(services, {%State{services: services}, []}, fn service, {acc, refs} ->
      case process_service(service) do
        {:ok, %{files: files, symbols: symbols}, references} ->
          {:cont,
           {%{acc | files: Map.merge(files, acc.files), symbols: Map.merge(symbols, acc.symbols)},
            [refs | references]}}

        {:error, reason} ->
          {:halt, {:error, reason}}
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

    unencoded_payload = process_common(service_name, service, descriptor)
    payload = FileDescriptorProto.encode(unencoded_payload)
    response = %{file_descriptor_proto: [payload]}

    root_symbols =
      method_symbols
      |> Enum.reduce(%{}, fn name, acc -> Map.put(acc, name, response) end)
      |> Map.put(service_name, response)

    root_files = %{(service_name <> ".proto") => response}

    {:ok, %State{files: root_files, symbols: root_symbols}, referenced_types}
  rescue
    _ -> {:error, "Couldn't process #{inspect(service)}"}
  end

  defp process_references([], data), do: data

  defp process_references([reference | rest], data) do
    if Map.has_key?(data.symbols, reference) do
      process_references(rest, data)
    else
      {%{files: f, symbols: s, extensions: e}, references} = process_reference(reference)

      data = %{
        data
        | files: Map.merge(data.files, f),
          symbols: Map.merge(data.symbols, s),
          extensions: Map.merge(data.extensions, e)
      }

      references = (rest ++ references) |> List.flatten() |> Enum.uniq()
      process_references(references, data)
    end
  end

  defp convert_symbol_to_module(symbol) do
    symbol
    |> then(fn
      "." <> name -> name
      name -> name
    end)
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn
      [m | segments] -> [m | Enum.map(segments, &Util.upcase_first/1)]
    end)
    |> Enum.reverse()
    |> Enum.join(".")
    |> then(fn name -> "Elixir." <> name end)
    |> String.to_existing_atom()
  end

  defp process_reference(symbol) do
    symbol
    |> convert_symbol_to_module()
    |> then(fn mod ->
      descriptor = mod.descriptor()
      name = symbol

      referenced_types = types_from_descriptor(descriptor)
      unencoded_payload = process_common(name, mod, descriptor)
      payload = FileDescriptorProto.encode(unencoded_payload)
      response = %{file_descriptor_proto: [payload]}

      root_symbols = %{symbol => response}
      root_files = %{(symbol <> ".proto") => response}

      extension_file = symbol <> "Extension.proto"

      {root_extensions, root_files} =
        process_extensions(mod, symbol, extension_file, descriptor, root_files)

      {%State{extensions: root_extensions, files: root_files, symbols: root_symbols},
       referenced_types}
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
      syntax: get_syntax(mod)
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
      for ext <- extension_files, is_message_descriptor?(ext) do
        ext.type_name
        |> convert_symbol_to_module()
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

  defp is_message_descriptor?(%Google.Protobuf.FieldDescriptorProto{type: @type_message}),
    do: true

  defp is_message_descriptor?(_), do: false

  defp process_common(name, module, descriptor) do
    package = Util.package_from_name(name)

    dependencies =
      descriptor
      |> types_from_descriptor()
      |> Enum.map(fn name ->
        name <> ".proto"
      end)
      |> Enum.uniq()

    response_stub =
      %FileDescriptorProto{
        name: name <> ".proto",
        package: package,
        dependency: dependencies,
        syntax: get_syntax(module)
      }

    case descriptor do
      %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
      %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
      %Google.Protobuf.EnumDescriptorProto{} -> %{response_stub | enum_type: [descriptor]}
    end
  end

  defp get_syntax(module) do
    cond do
      Keyword.has_key?(module.__info__(:functions), :__message_props__) ->
        # this is a message type
        case module.__message_props__().syntax do
          :proto2 -> "proto2"
          :proto3 -> "proto3"
        end

      Keyword.has_key?(module.__info__(:functions), :__rpc_calls__) ->
        # this is a service definition, grab a message and recurse
        module.__rpc_calls__()
        |> Enum.find(fn
          {_, _, _} -> true
          _ -> false
        end)
        |> then(fn
          nil -> "proto2"
          {_, {req, _}, _} -> get_syntax(req)
          {_, _, {req, _}} -> get_syntax(req)
        end)

      true ->
        raise "Module #{inspect(module)} has neither rcp_calls nor __message_props__"
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
    (descriptor.field ++ Enum.flat_map(descriptor.nested_type, & &1.field))
    |> Enum.map(fn field ->
      field.type_name
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn
      "." <> symbol -> symbol
      symbol -> symbol
    end)
  end

  defp types_from_descriptor(%Google.Protobuf.EnumDescriptorProto{}) do
    []
  end

  defmodule Util do
    @moduledoc """
    Utility functions for the builder.
    """
    @field_type_mapping Google.Protobuf.FieldDescriptorProto.Type.mapping()
    @field_label_mapping Google.Protobuf.FieldDescriptorProto.Label.mapping()

    def package_from_name(service_name) do
      service_name
      |> String.split(".")
      |> Enum.reverse()
      |> then(fn [_ | rest] -> rest end)
      |> Enum.reverse()
      |> Enum.join(".")
    end

    def upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

    def downcase_first(<<first::utf8, rest::binary>>),
      do: String.downcase(<<first::utf8>>) <> rest

    # Generates a field descriptor from a field props struct. This function is compatible with proto2 only.
    def convert_to_field_descriptor(
          extendee,
          %Protobuf.Extension.Props.Extension{field_props: field_props}
        ) do
      {type, type_name} = type_from_field_props(field_props)

      %Google.Protobuf.FieldDescriptorProto{
        name: field_props.name,
        number: field_props.fnum,
        label: label_from_field_props(field_props),
        type: type,
        type_name: type_name,
        extendee: extendee
      }
    end

    # Google.Protobuf.FieldDescriptorProto.Label
    defp label_from_field_props(%Protobuf.FieldProps{optional?: true}),
      do: @field_label_mapping[:LABEL_OPTIONAL]

    defp label_from_field_props(%Protobuf.FieldProps{repeated?: true}),
      do: @field_label_mapping[:LABEL_REPEATED]

    defp label_from_field_props(%Protobuf.FieldProps{required?: true}),
      do: @field_label_mapping[:LABEL_REQUIRED]

    # Google.Protobuf.FieldDescriptorProto.Type
    defp type_from_field_props(%Protobuf.FieldProps{type: type}) do
      @field_type_mapping
      |> Map.get(:"TYPE_#{type |> Atom.to_string() |> String.upcase()}", type)
      |> then(fn type ->
        cond do
          is_integer(type) ->
            {type, nil}

          is_atom(type) and Code.ensure_loaded?(type) and function_exported?(type, :descriptor, 0) ->
            {@field_type_mapping[:TYPE_MESSAGE], get_pb_type_name(type)}

          true ->
            raise("Unsupported type")
        end
      end)
    end

    defp get_pb_type_name(type) do
      {packs, [name]} =
        type
        |> Module.split()
        |> Enum.split(-1)

      Enum.map_join(packs, ".", &downcase_first/1) <> "." <> name
    end
  end
end
