defmodule GrpcReflection.GraphCheck do
  @moduledoc """
  Link-checks a built reflection state the way a reflection client would.

  A client resolves every dependency of a file before using it, then resolves every
  type name against what the file and its direct dependencies define. This module
  returns a list of human readable violations (empty when the graph is sound).
  """

  alias Google.Protobuf.DescriptorProto
  alias Google.Protobuf.FileDescriptorProto

  def violations(%GrpcReflection.Service.State{files: files, symbols: symbols}) do
    defined = Map.new(files, fn {name, file} -> {name, defined_symbols(file)} end)

    missing_dependencies(files) ++
      dependency_cycles(files) ++
      unresolved_types(files, defined) ++
      misplaced_symbols(files, symbols, defined)
  end

  defp missing_dependencies(files) do
    for {name, file} <- files, dep <- file.dependency, not is_map_key(files, dep) do
      "#{name} depends on #{dep}, which does not exist"
    end
  end

  defp dependency_cycles(files) do
    graph = Map.new(files, fn {name, file} -> {name, file.dependency} end)

    files
    |> Map.keys()
    |> Enum.sort()
    |> Enum.flat_map(&cycle_through(&1, graph))
    |> Enum.uniq()
  end

  # reports the first cycle reachable from `node` that passes back through `node`
  defp cycle_through(node, graph) do
    if reaches?(graph, Map.get(graph, node, []), node, MapSet.new()),
      do: ["#{node} is part of a dependency cycle"],
      else: []
  end

  defp reaches?(_graph, [], _target, _seen), do: false

  defp reaches?(graph, [current | rest], target, seen) do
    cond do
      current == target ->
        true

      current in seen ->
        reaches?(graph, rest, target, seen)

      true ->
        reaches?(graph, Map.get(graph, current, []) ++ rest, target, MapSet.put(seen, current))
    end
  end

  defp unresolved_types(files, defined) do
    for {name, file} <- files,
        visible = visible_symbols(file, defined),
        type <- referenced_types(file),
        type not in visible do
      "#{name} references #{type}, which it neither defines nor imports"
    end
  end

  defp visible_symbols(file, defined) do
    deps = Enum.map(file.dependency, &Map.get(defined, &1, MapSet.new()))
    Enum.reduce(deps, defined[file.name], &MapSet.union/2)
  end

  defp misplaced_symbols(files, symbols, defined) do
    for {symbol, filename} <- symbols,
        not (is_map_key(files, filename) and symbol in defined[filename]) do
      "symbol #{symbol} maps to #{filename}, which does not define it"
    end
  end

  defp defined_symbols(%FileDescriptorProto{} = file) do
    prefix = file.package || ""

    messages = Enum.flat_map(file.message_type, &message_symbols(prefix, &1))
    enums = Enum.map(file.enum_type, &qualify(prefix, &1.name))

    services =
      Enum.flat_map(file.service, fn service ->
        service_symbol = qualify(prefix, service.name)
        [service_symbol | Enum.map(service.method, &(service_symbol <> "." <> &1.name))]
      end)

    MapSet.new(messages ++ enums ++ services)
  end

  defp message_symbols(prefix, %DescriptorProto{} = message) do
    symbol = qualify(prefix, message.name)

    nested = Enum.flat_map(message.nested_type, &message_symbols(symbol, &1))
    enums = Enum.map(message.enum_type, &qualify(symbol, &1.name))

    [symbol | nested ++ enums]
  end

  defp referenced_types(%FileDescriptorProto{} = file) do
    message_types = Enum.flat_map(file.message_type, &message_references/1)

    method_types =
      for service <- file.service,
          method <- service.method,
          type <- [method.input_type, method.output_type],
          do: trim(type)

    extension_types =
      for ext <- file.extension, type <- [ext.type_name, ext.extendee], type, do: trim(type)

    Enum.uniq(message_types ++ method_types ++ extension_types)
  end

  defp message_references(%DescriptorProto{} = message) do
    own = for field <- message.field, field.type_name, do: trim(field.type_name)
    Enum.uniq(own ++ Enum.flat_map(message.nested_type, &message_references/1))
  end

  defp qualify("", name), do: name
  defp qualify(prefix, name), do: prefix <> "." <> name

  defp trim("." <> symbol), do: symbol
  defp trim(symbol), do: symbol
end
