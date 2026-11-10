defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.Builder.Extensions
  alias GrpcReflection.Service.Builder.Nesting
  alias GrpcReflection.Service.Builder.Util
  alias GrpcReflection.Service.State

  require Logger

  def build_reflection_tree(services) do
    with :ok <- Util.validate_services(services) do
      nested = Nesting.index(services)

      tree =
        services
        |> Enum.reduce(State.new(), fn service, state ->
          new_state = process_service(service, nested)
          State.merge(state, new_state)
        end)
        # dependencies must name real files before looking for cycles: an edge to a nested
        # type only closes a cycle once it is rewritten to the file of its enclosing message
        |> resolve_dependencies()
        |> State.shrink_cycles()
        |> report_missing_dependencies()
        # only needed while building
        |> Map.merge(%{nested: %{}, traced: MapSet.new()})

      {:ok, tree}
    end
  end

  defp process_service(service, nested) do
    service_name = service.__meta__(:name)
    state = State.new([service], nested)
    service_response = build_response(state, service_name, service)

    state
    |> State.add_file(service_response)
    |> State.add_symbol(service_name, service_response.name)
    |> trace_service_refs(service, service_response.name)
  end

  defp trace_service_refs(state, module, module_filename) do
    service_name = module.__meta__(:name)
    methods = get_descriptor(state, module).method

    module.__rpc_calls__()
    |> Enum.reduce(state, fn call, state ->
      {function, {request, _}, {response, _}, _} = call

      %{input_type: req_symbol, output_type: resp_symbol} =
        Enum.find(methods, fn method -> method.name == to_string(function) end)

      call_symbol = service_name <> "." <> to_string(function)

      state
      |> State.add_symbol(call_symbol, module_filename)
      |> trace_type(Util.trim_symbol(req_symbol), request)
      |> trace_type(Util.trim_symbol(resp_symbol), response)
    end)
  end

  # A nested type is not a file of its own: it lives in the file of the outermost message
  # that encloses it. Whatever references a type, it is that message we trace, and then
  # the nested type itself, whose module we were just handed.
  defp trace_type(state, symbol, module) do
    {top_symbol, top_module} = Nesting.top_level(symbol, module)

    state
    |> trace_top_level(top_symbol, top_module)
    |> trace_members([{symbol, module}])
  end

  defp trace_top_level(state, symbol, _module) when is_map_key(state.symbols, symbol), do: state

  defp trace_top_level(state, symbol, module) do
    response = build_response(state, symbol, module)
    members = [{symbol, module} | nested_members(state, symbol, module)]

    members
    |> Enum.reduce(State.add_file(state, response), fn {member_symbol, _}, state ->
      State.add_symbol(state, member_symbol, response.name)
    end)
    |> trace_members(members)
  end

  # every message and enum declared in a message's file, as `{symbol, module}`
  defp nested_members(state, symbol, module) do
    descriptor = get_descriptor(state, module)

    for nested_symbol <- Util.get_nested_types(symbol, descriptor) do
      {nested_symbol, nested_module(nested_symbol, module, symbol)}
    end
  end

  defp nested_module(nested_symbol, top_module, top_symbol) do
    nested_symbol
    |> String.replace_prefix(top_symbol <> ".", "")
    |> String.split(".")
    |> Enum.reduce_while(top_module, fn name, parent ->
      case Nesting.child_module(parent, name) do
        {:ok, child} -> {:cont, child}
        :error -> {:halt, nil}
      end
    end)
  end

  # Follow the types a message refers to, once. Members whose module we could not find are
  # skipped: they are traced if something refers to them, and left out of the tree if not.
  defp trace_members(state, members) do
    Enum.reduce(members, state, fn
      {_symbol, nil}, state ->
        state

      {symbol, module}, state ->
        if MapSet.member?(state.traced, symbol) do
          state
        else
          %{state | traced: MapSet.put(state.traced, symbol)}
          |> Extensions.add_extensions(symbol, module)
          |> trace_message_refs(module)
        end
    end)
  end

  defp trace_message_refs(state, module) do
    case get_descriptor(state, module) do
      %{field: fields} -> trace_message_fields(state, module, fields)
      _ -> state
    end
  end

  defp trace_message_fields(state, module, fields) do
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
      trace_type(state, Util.trim_symbol(symbol), mod)
    end)
  end

  defp build_response(state, symbol, module) do
    # we build our own file responses, so unwrap any present
    descriptor = get_descriptor(state, module)

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
  # with their ancestor, so that filename may not exist. Must run before shrink_cycles,
  # which needs real filenames to see cycles that pass through nested types.
  #
  # Drop self-dependencies: a message that refers to itself, or a nested type that refers
  # to its enclosing message, resolves to its own file. shrink_cycles skips single-file
  # cycles, and a client resolves every dependency before using a file, so it would never
  # finish loading a file that depends on itself.
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
          |> Enum.reject(&(&1 == filename))

        {filename, %{descriptor | dependency: resolved_deps}}
      end)

    %{state | files: resolved_files}
  end

  # A file that depends on a file we never built cannot be loaded by a client, and takes
  # every file that depends on it along. That can only mean something was not traced, so
  # say so loudly at startup, not as an obscure failure in a client later. The rest of the
  # tree is still served.
  defp report_missing_dependencies(%State{files: files} = state) do
    for {filename, file} <- Enum.sort(files),
        dependency <- file.dependency,
        not is_map_key(files, dependency) do
      Logger.error(
        "reflection built #{filename}, but it depends on #{dependency}, which was never built; " <>
          "clients will not be able to load it"
      )
    end

    state
  end

  # protoc with the elixir generator and protobuf.generate slightly differ for how they
  # generate descriptors.  Use this to potentially unwrap the service proto when dealing
  # with descriptors that could come from a service module.
  defp get_descriptor(%State{} = state, module) do
    cond do
      not Code.ensure_loaded?(module) ->
        raise "Module #{inspect(module)} is not loaded"

      function_exported?(module, :descriptor, 0) ->
        case module.descriptor() do
          %FileDescriptorProto{service: [proto]} -> proto
          proto -> proto
        end

      true ->
        synthesize_descriptor(module, state.nested)
    end
  end

  defp synthesize_descriptor(module, nested) do
    cond do
      function_exported?(module, :__rpc_calls__, 0) ->
        GrpcReflection.Service.Builder.Synthesizer.service_descriptor(module)

      function_exported?(module, :mapping, 0) ->
        GrpcReflection.Service.Builder.Synthesizer.enum_descriptor(module)

      function_exported?(module, :__message_props__, 0) ->
        GrpcReflection.Service.Builder.Synthesizer.message_descriptor(module, nested)

      true ->
        # unreachable in practice: validate_services/1 only admits modules that export
        # __rpc_calls__/0, __message_props__/0, or descriptor/0, so a module reaching
        # synthesize_descriptor/1 without any of those three is impossible.
        raise "Module #{inspect(module)} exports neither descriptor/0, __rpc_calls__/0, nor __message_props__/0 — cannot synthesize a descriptor"
    end
  end
end
