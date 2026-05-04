defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.Builder.Extensions
  alias GrpcReflection.Service.Builder.Util
  alias GrpcReflection.Service.State

  def build_reflection_tree(services) do
    with :ok <- Util.validate_services(services) do
      tree =
        services
        |> Enum.reduce(State.new(), fn service, state ->
          new_state = process_service(service)
          State.merge(state, new_state)
        end)
        # shrink_cycles must run first so the symbol table reflects final merged filenames
        # before resolve_dependencies rewrites dep strings through it
        |> State.shrink_cycles()
        |> resolve_dependencies()

      {:ok, tree}
    end
  end

  defp process_service(service) do
    service_name = service.__meta__(:name)
    service_response = build_response(service_name, service)

    [service]
    |> State.new()
    |> State.add_file(service_response)
    |> State.add_symbol(service_name, service_response.name)
    |> trace_service_refs(service, service_response.name)
  end

  defp trace_service_refs(state, module, module_filename) do
    service_name = module.__meta__(:name)
    methods = get_descriptor(module).method

    module.__rpc_calls__()
    |> Enum.reduce(state, fn call, state ->
      {function, {request, _}, {response, _}, _} = call

      %{input_type: req_symbol, output_type: resp_symbol} =
        Enum.find(methods, fn method -> method.name == to_string(function) end)

      call_symbol = service_name <> "." <> to_string(function)

      req_symbol = Util.trim_symbol(req_symbol)
      req_response = build_response(req_symbol, request)
      req_filename = req_symbol <> ".proto"
      resp_symbol = Util.trim_symbol(resp_symbol)
      resp_response = build_response(resp_symbol, response)
      resp_filename = resp_symbol <> ".proto"

      state
      |> Extensions.add_extensions(service_name, module)
      |> State.add_file(req_response)
      |> State.add_file(resp_response)
      |> State.add_symbol(call_symbol, module_filename)
      |> State.add_symbol(req_symbol, req_filename)
      |> State.add_symbol(resp_symbol, resp_filename)
      |> Extensions.add_extensions(req_symbol, request)
      |> Extensions.add_extensions(resp_symbol, response)
      |> trace_message_refs(req_symbol, request)
      |> trace_message_refs(resp_symbol, response)
    end)
  end

  defp trace_message_refs(state, parent_symbol, module) do
    case get_descriptor(module) do
      %{field: fields} ->
        trace_message_fields(state, parent_symbol, module, fields)

      _ ->
        state
    end
  end

  defp trace_message_fields(state, parent_symbol, module, fields) do
    nested_types = Util.get_nested_types(parent_symbol, get_descriptor(module))

    module.__message_props__().field_props
    |> Map.values()
    |> Enum.map(fn %{name: name, type: type} ->
      mod =
        case type do
          {_, mod} -> mod
          mod -> mod
        end

      %{mod: mod, symbol: Enum.find(fields, fn f -> f.name == name end).type_name}
    end)
    |> Enum.reject(fn %{symbol: s} -> is_nil(s) end)
    |> Enum.reduce(state, fn %{mod: mod, symbol: symbol}, state ->
      trace_field_ref(state, parent_symbol, Util.trim_symbol(symbol), mod, nested_types)
    end)
  end

  defp trace_field_ref(state, _parent_symbol, symbol, _mod, _nested_types)
       when is_map_key(state.symbols, symbol),
       do: state

  defp trace_field_ref(state, parent_symbol, symbol, mod, nested_types) do
    {file, filename} =
      if symbol in nested_types do
        # nested types belong in the same file as their ancestor — look it up rather
        # than building a new synthetic file (which would have wrong FQDNs)
        parent_filename = state.symbols[parent_symbol]
        {state.files[parent_filename], parent_filename}
      else
        response = build_response(symbol, mod)
        {response, response.name}
      end

    state
    |> Extensions.add_extensions(symbol, mod)
    |> State.add_file(file)
    |> State.add_symbol(symbol, filename)
    |> trace_message_refs(symbol, mod)
  end

  defp build_response(symbol, module) do
    # we build our own file responses, so unwrap any present
    descriptor = get_descriptor(module)

    dependencies =
      descriptor
      |> Util.types_from_descriptor()
      |> Enum.uniq()
      |> Kernel.--(Util.get_nested_types(symbol, descriptor))
      |> Enum.map(fn name ->
        Util.trim_symbol(name) <> ".proto"
      end)

    syntax = Util.get_syntax(module)

    response_stub =
      %FileDescriptorProto{
        name: symbol <> ".proto",
        package: Util.get_package(symbol),
        dependency: dependencies,
        syntax: syntax
      }

    case descriptor = descriptor do
      %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
      %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
      %Google.Protobuf.EnumDescriptorProto{} -> %{response_stub | enum_type: [descriptor]}
    end
  end

  # Rewrite each file's dependency list to use actual filenames from the symbol table.
  # build_response names deps as `type_symbol <> ".proto"`, but nested types share a file
  # with their ancestor, so that filename may not exist. Must run after shrink_cycles so
  # merged cycle filenames are already reflected in the symbol table.
  defp resolve_dependencies(%State{files: files, symbols: symbols} = state) do
    resolved_files =
      Map.new(files, fn {filename, descriptor} ->
        resolved_deps =
          descriptor.dependency
          |> Enum.map(fn dep ->
            type_symbol = String.trim_trailing(dep, ".proto")
            symbols[type_symbol] || dep
          end)
          |> Enum.uniq()

        {filename, %{descriptor | dependency: resolved_deps}}
      end)

    %{state | files: resolved_files}
  end

  # protoc with the elixir generator and protobuf.generate slightly differ for how they
  # generate descriptors.  Use this to potentially unwrap the service proto when dealing
  # with descriptors that could come from a service module.
  defp get_descriptor(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :descriptor, 0) do
      case module.descriptor() do
        %FileDescriptorProto{service: [proto]} -> proto
        proto -> proto
      end
    else
      synthesize_descriptor(module)
    end
  end

  defp synthesize_descriptor(module) do
    cond do
      function_exported?(module, :__rpc_calls__, 0) ->
        GrpcReflection.Service.Builder.Synthesizer.service_descriptor(module)

      function_exported?(module, :mapping, 0) ->
        GrpcReflection.Service.Builder.Synthesizer.enum_descriptor(module)

      function_exported?(module, :__message_props__, 0) ->
        GrpcReflection.Service.Builder.Synthesizer.message_descriptor(module)

      true ->
        # unreachable in practice: validate_services/1 only admits modules that export
        # __rpc_calls__/0, __message_props__/0, or descriptor/0, so a module reaching
        # synthesize_descriptor/1 without any of those three is impossible.
        raise "Module #{inspect(module)} exports neither descriptor/0, __rpc_calls__/0, nor __message_props__/0 — cannot synthesize a descriptor"
    end
  end
end
