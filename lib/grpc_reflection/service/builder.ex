defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.Builder.Acc
  alias GrpcReflection.Service.Builder.Extensions
  alias GrpcReflection.Service.Builder.Util
  alias GrpcReflection.Service.State

  @spec build_reflection_tree(any()) ::
          {:error, <<_::216>>} | {:ok, GrpcReflection.Service.State.t()}
  def build_reflection_tree(services) do
    with :ok <- Util.validate_services(services) do
      acc =
        Enum.reduce(services, %Acc{services: services}, fn service, acc ->
          process_service(acc, service)
        end)

      {:ok, finalize(acc)}
    end
  end

  defp finalize(%Acc{} = acc) do
    files = build_files(acc)

    symbols =
      acc.symbol_info
      |> Enum.reduce(%{}, fn {symbol, info}, map ->
        Map.put(map, symbol, Map.fetch!(files, info.file))
      end)
      |> then(fn base ->
        Enum.reduce(acc.aliases, base, fn {alias_symbol, target_symbol}, map ->
          payload = Map.fetch!(map, target_symbol)
          Map.put(map, alias_symbol, payload)
        end)
      end)

    State.new(acc.services)
    |> State.add_files(Map.merge(files, acc.extension_files))
    |> State.add_symbols(symbols)
    |> State.add_extensions(acc.extensions)
  end

  defp build_files(%Acc{} = acc) do
    acc.symbol_info
    |> Enum.group_by(fn {_symbol, info} -> info.file end)
    |> Enum.reduce(%{}, fn {file_name, entries}, files ->
      descriptors = Enum.map(entries, fn {_symbol, info} -> info end)

      syntax = descriptors |> List.first() |> Map.fetch!(:syntax)
      package = descriptors |> List.first() |> Map.fetch!(:package)

      dependencies =
        descriptors
        |> Enum.flat_map(& &1.deps)
        |> Enum.map(&resolve_dependency_file(&1, acc))
        |> Enum.reject(&is_nil/1)
        |> Enum.reject(&(&1 == file_name))
        |> Enum.uniq()

      {messages, enums, services} =
        Enum.reduce(descriptors, {[], [], []}, fn %{descriptor: descriptor},
                                                  {messages, enums, services} ->
          case descriptor do
            %Google.Protobuf.DescriptorProto{} ->
              {[descriptor | messages], enums, services}

            %Google.Protobuf.EnumDescriptorProto{} ->
              {messages, [descriptor | enums], services}

            %Google.Protobuf.ServiceDescriptorProto{} ->
              {messages, enums, [descriptor | services]}
          end
        end)
        |> then(fn {messages, enums, services} ->
          {Enum.reverse(messages), Enum.reverse(enums), Enum.reverse(services)}
        end)

      file_proto = %FileDescriptorProto{
        name: file_name,
        package: package,
        dependency: dependencies,
        syntax: syntax,
        message_type: messages,
        enum_type: enums,
        service: services
      }

      Map.put(files, file_name, %{file_descriptor_proto: [FileDescriptorProto.encode(file_proto)]})
    end)
  end

  defp process_service(%Acc{} = acc, service) do
    service_name = service.__meta__(:name)
    {acc, _} = register_symbol(acc, service_name, service, :service)

    methods = get_descriptor(service).method

    Enum.reduce(service.__rpc_calls__(), acc, fn call, acc ->
      {function, {req, _}, {resp, _}, _} = call

      %{input_type: req_symbol, output_type: resp_symbol} =
        Enum.find(methods, fn method -> method.name == to_string(function) end)

      req_symbol = Util.trim_symbol(req_symbol)
      resp_symbol = Util.trim_symbol(resp_symbol)

      method_symbol = service_name <> "." <> to_string(function)

      acc
      |> register_alias(method_symbol, service_name)
      |> Extensions.add_extensions(service_name, service)
      |> process_message(req_symbol, req)
      |> process_message(resp_symbol, resp)
    end)
  end

  defp process_message(%Acc{} = acc, nil, _module, _root_symbol), do: acc

  defp process_message(%Acc{} = acc, symbol, module, root_symbol) do
    symbol = Util.trim_symbol(symbol)
    root_symbol = root_symbol || symbol

    {acc, already_processed} =
      if root_symbol == symbol do
        register_symbol(acc, symbol, module, :message)
      else
        acc = register_alias(acc, symbol, root_symbol)

        if MapSet.member?(acc.visited, symbol) do
          {acc, true}
        else
          {acc, false}
        end
      end

    if already_processed do
      acc
    else
      acc = %{acc | visited: MapSet.put(acc.visited, symbol)}
      acc = Extensions.add_extensions(acc, symbol, module)

      case module.descriptor() do
        %{field: fields} = descriptor ->
          nested_symbols = Util.get_nested_types(symbol, descriptor)

          module.__message_props__().field_props
          |> Map.values()
          |> Enum.map(fn %{name: name, type: type} ->
            %{
              mod:
                case type do
                  {_, mod} -> mod
                  mod -> mod
                end,
              symbol: Enum.find(fields, fn f -> f.name == name end).type_name
            }
          end)
          |> Enum.reject(fn %{symbol: s} -> is_nil(s) end)
          |> Enum.reduce(acc, fn %{mod: mod, symbol: child_symbol}, acc ->
            child_symbol = Util.trim_symbol(child_symbol)

            if child_symbol in nested_symbols do
              process_message(acc, child_symbol, mod, root_symbol)
            else
              process_message(acc, child_symbol, mod)
            end
          end)

        _ ->
          acc
      end
    end
  end

  defp process_message(%Acc{} = acc, symbol, module) do
    process_message(acc, symbol, module, nil)
  end

  defp register_symbol(%Acc{} = acc, symbol, module, kind) do
    symbol = Util.trim_symbol(symbol)

    if Map.has_key?(acc.symbol_info, symbol) do
      {acc, true}
    else
      descriptor = get_descriptor(module)

      info = %{
        descriptor: descriptor,
        deps:
          descriptor
          |> Util.types_from_descriptor()
          |> Enum.map(&Util.trim_symbol/1)
          |> Enum.uniq(),
        file: Util.proto_filename(module),
        syntax: Util.get_syntax(module),
        package: Util.get_package(symbol),
        kind: kind
      }

      {%{
         acc
         | symbol_info: Map.put(acc.symbol_info, symbol, info),
           visited: MapSet.put(acc.visited, symbol)
       }, false}
    end
  end

  defp register_alias(%Acc{} = acc, alias_symbol, target_symbol) do
    alias_symbol = Util.trim_symbol(alias_symbol)
    target_symbol = Util.trim_symbol(target_symbol)

    cond do
      alias_symbol == target_symbol -> acc
      Map.get(acc.aliases, alias_symbol) == target_symbol -> acc
      true -> %{acc | aliases: Map.put(acc.aliases, alias_symbol, target_symbol)}
    end
  end

  defp resolve_dependency_file(nil, _acc), do: nil

  defp resolve_dependency_file(symbol, %Acc{} = acc) do
    symbol = Util.trim_symbol(symbol)

    cond do
      info = Map.get(acc.symbol_info, symbol) ->
        info.file

      target = Map.get(acc.aliases, symbol) ->
        acc.symbol_info
        |> Map.get(target)
        |> case do
          nil -> symbol <> ".proto"
          info -> info.file
        end

      true ->
        symbol <> ".proto"
    end
  end

  defp get_descriptor(module) do
    case module.descriptor() do
      %FileDescriptorProto{service: [proto]} -> proto
      proto -> proto
    end
  end
end
