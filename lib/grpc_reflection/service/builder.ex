defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias Google.Protobuf.ServiceDescriptorProto
  alias GrpcReflection.Service.State
  alias GrpcReflection.Service.Builder.Util

  def build_reflection_tree(services) do
    with :ok <- Util.validate_services(services) do
      services
      |> process_services()
      |> process_references()
      |> enhance_with_file_based_descriptors(services)
    end
  end

  # New: Enhance state with file-based descriptors
  defp enhance_with_file_based_descriptors({:ok, state}, services) do
    case build_file_based_descriptors(services, state) do
      {:ok, file_descriptors, message_to_file} ->
        enhanced_state =
          state
          |> State.add_file_descriptors(file_descriptors)
          |> State.add_message_to_file_mappings(message_to_file)

        {:ok, enhanced_state}

      {:error, reason} ->
        # Log error but continue with existing state for backward compatibility
        require Logger
        Logger.warning("Failed to build file-based descriptors: #{inspect(reason)}")
        {:ok, state}
    end
  end

  defp enhance_with_file_based_descriptors(error, _services), do: error

  # New: Build file-based descriptors
  defp build_file_based_descriptors(services, state) do
    try do
      # Extract all modules (messages and services) from the state
      all_modules = extract_all_modules(services, state)

      # Group modules by their likely source file
      file_groups = group_modules_by_source_file(all_modules)

      # Generate file descriptors for each group
      file_descriptors = generate_file_descriptors_for_groups(file_groups)

      # Create message-to-file mapping
      message_to_file = create_message_to_file_mapping(file_groups, file_descriptors)

      {:ok, file_descriptors, message_to_file}
    rescue
      error -> {:error, error}
    end
  end

  # Extract all modules from services and referenced types
  defp extract_all_modules(services, state) do
    # Get all services
    service_modules = services

    # Get all referenced modules from symbols
    referenced_modules =
      state.symbols
      |> Map.keys()
      |> Enum.map(fn symbol ->
        try do
          Util.convert_symbol_to_module(symbol)
        rescue
          _ -> nil
        end
      end)
      |> Enum.filter(fn module ->
        module != nil and Code.ensure_loaded?(module)
      end)

    # Combine and deduplicate
    (service_modules ++ referenced_modules)
    |> Enum.uniq()
  end

  # Group modules by their likely source file based on module structure
  defp group_modules_by_source_file(modules) do
    modules
    |> Enum.group_by(&infer_source_file/1)
    |> Enum.into(%{})
  end

  # Infer source file from module name and structure
  defp infer_source_file(module) do
    module_parts = Module.split(module)

    case module_parts do
      # Service modules: Helloworld.Greeter.Service -> "helloworld.proto"
      [namespace, _service_name, "Service"] ->
        namespace_path = namespace |> Macro.underscore()
        "#{namespace_path}.proto"

      # Message modules: All messages in same namespace go to same file
      # Helloworld.HelloRequest -> "helloworld.proto"
      # Helloworld.HelloReply -> "helloworld.proto"
      [namespace | _rest] ->
        namespace_path = namespace |> Macro.underscore()
        "#{namespace_path}.proto"

      # Fallback for modules without clear namespace
      _ ->
        module_name = module |> Module.split() |> List.first() |> Macro.underscore()
        "#{module_name}.proto"
    end
  end

  # Generate file descriptors for each file group
  defp generate_file_descriptors_for_groups(file_groups) do
    file_groups
    |> Enum.map(fn {source_file, modules} ->
      {source_file, generate_file_descriptor_for_group(source_file, modules)}
    end)
    |> Enum.into(%{})
  end

  # Generate a single file descriptor for a group of modules
  defp generate_file_descriptor_for_group(source_file, modules) do
    # Separate services and messages
    {services, messages} = partition_services_and_messages(modules)

    # Extract package name from the first module
    package =
      case modules do
        [first_module | _] -> extract_package_from_module(first_module)
        [] -> ""
      end

    # Get syntax from the first module
    syntax =
      case modules do
        [first_module | _] -> Util.get_syntax(first_module)
        [] -> "proto3"
      end

    # Collect all dependencies
    dependencies = collect_dependencies_for_modules(modules)

    # Build service descriptors
    service_descriptors =
      Enum.map(services, fn service ->
        service.descriptor()
      end)

    # Build message descriptors
    message_descriptors =
      Enum.map(messages, fn message ->
        message.descriptor()
      end)

    # Create file descriptor
    file_descriptor = %FileDescriptorProto{
      name: source_file,
      package: package,
      dependency: dependencies,
      message_type: message_descriptors,
      service: service_descriptors,
      syntax: syntax
    }

    # Encode to binary
    FileDescriptorProto.encode(file_descriptor)
  end

  # Partition modules into services and messages
  defp partition_services_and_messages(modules) do
    Enum.split_with(modules, fn module ->
      # Check if it's a service module
      case Module.split(module) do
        [_, _, "Service"] ->
          true

        _ ->
          # Also check if it has service-related functions
          Code.ensure_loaded?(module) and
            function_exported?(module, :__rpc_calls__, 0)
      end
    end)
  end

  # Extract package name from module
  defp extract_package_from_module(module) do
    # Use the existing Util.get_package logic but adapt it
    module_parts = Module.split(module)

    case module_parts do
      [namespace | _] -> namespace |> Macro.underscore()
      [] -> ""
    end
  end

  # Collect dependencies for a group of modules
  defp collect_dependencies_for_modules(modules) do
    modules
    |> Enum.flat_map(fn module ->
      case get_module_descriptor(module) do
        nil -> []
        descriptor -> Util.types_from_descriptor(descriptor)
      end
    end)
    |> Enum.uniq()
    |> Enum.reject(fn type ->
      # Filter out types that are defined in the same file group
      type_module = Util.convert_symbol_to_module(type)
      Enum.member?(modules, type_module)
    end)
    |> Enum.map(&(&1 <> ".proto"))
  end

  # Get descriptor from module safely
  defp get_module_descriptor(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :descriptor, 0) do
      module.descriptor()
    else
      nil
    end
  end

  # Create message-to-file mapping
  defp create_message_to_file_mapping(file_groups, file_descriptors) do
    file_groups
    |> Enum.flat_map(fn {source_file, modules} ->
      file_descriptor_binary = Map.get(file_descriptors, source_file)

      # Only include message modules, not service modules
      {_services, messages} = partition_services_and_messages(modules)

      Enum.map(messages, fn message_module ->
        {message_module, file_descriptor_binary}
      end)
    end)
    |> Enum.into(%{})
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
    name = service.__meta__(:name)
    syntax = Util.get_syntax(service)

    # protobuf_elixir populates service descriptors directly
    # protobuf_generate populates services with file_descriptors
    case service.descriptor() do
      %FileDescriptorProto{service: [proto]} ->
        # we should read and use the file descriptor directly instead
        # of dropping relevant data and trying to discover it
        process_service_descriptor(name, proto, syntax)

      %ServiceDescriptorProto{} = proto ->
        process_service_descriptor(name, proto, syntax)
    end
  end

  defp process_service_descriptor(service_name, descriptor, syntax) do
    referenced_types = Util.types_from_descriptor(descriptor)

    method_symbols =
      Enum.map(
        descriptor.method,
        fn method -> service_name <> "." <> method.name end
      )

    unencoded_payload = process_common(service_name, descriptor, syntax)
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

      nested_types = Util.get_nested_types(name, descriptor)

      referenced_types =
        Util.types_from_descriptor(descriptor)
        |> Enum.uniq()
        |> Kernel.--(nested_types)

      unencoded_payload = process_common(name, descriptor, Util.get_syntax(mod), nested_types)
      payload = FileDescriptorProto.encode(unencoded_payload)
      response = %{file_descriptor_proto: [payload]}

      root_symbols = %{symbol => response}

      root_symbols =
        Enum.reduce(nested_types, root_symbols, fn name, acc -> Map.put(acc, name, response) end)

      root_files = %{(symbol <> ".proto") => response}

      root_files =
        Enum.reduce(nested_types, root_files, fn name, acc ->
          Map.put(acc, name <> ".proto", response)
        end)

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
      package: Util.get_package(symbol),
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
      for ext <- extension_files, Util.message_descriptor?(ext) do
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

  defp process_common(name, descriptor, syntax, nested_types \\ []) do
    dependencies =
      descriptor
      |> Util.types_from_descriptor()
      |> Enum.uniq()
      |> Kernel.--(nested_types)
      |> Enum.map(fn name ->
        name <> ".proto"
      end)

    response_stub =
      %FileDescriptorProto{
        name: name <> ".proto",
        package: Util.get_package(name),
        dependency: dependencies,
        syntax: syntax
      }

    case descriptor do
      %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
      %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
      %Google.Protobuf.EnumDescriptorProto{} -> %{response_stub | enum_type: [descriptor]}
    end
  end
end
