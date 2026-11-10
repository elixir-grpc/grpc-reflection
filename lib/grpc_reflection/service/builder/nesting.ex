defmodule GrpcReflection.Service.Builder.Nesting do
  @moduledoc false

  # protoc-gen-elixir names a nested type's module after its parent's module
  # (`Pkg.Outer.Inner` for `pkg.Outer.Inner`), and records the proto name in `full_name`.
  # That lets us find a type's enclosing message from the module alone, without relying
  # on naming conventions of the proto symbols themselves.

  @doc """
  Returns `{symbol, module}` for the outermost message that encloses the given type.
  A type that is not nested is its own outermost message.
  """
  def top_level(symbol, module) do
    case parent(symbol, module) do
      {parent_symbol, parent_module} -> top_level(parent_symbol, parent_module)
      nil -> {symbol, module}
    end
  end

  @doc """
  Maps each message module to the modules declared directly inside it, for every type
  reachable from the services.

  Without descriptors nothing records which types are nested, so a synthesized message
  has to learn its nested types from here. It is computed once for all services, so that
  a message synthesizes to the same descriptor no matter which service reached it.
  """
  def index(services) do
    services
    |> Enum.flat_map(&rpc_types/1)
    |> reachable(MapSet.new())
    |> Enum.reduce(%{}, fn module, index ->
      case enclosing_message(module) do
        {_symbol, parent_module} -> Map.update(index, parent_module, [module], &[module | &1])
        nil -> index
      end
    end)
    |> Map.new(fn {parent, children} -> {parent, Enum.sort_by(children, &full_name/1)} end)
  end

  @doc """
  Returns `{symbol, module}` of the message directly enclosing the given type, or `nil`
  if the type is not nested.
  """
  def parent(symbol, module) do
    with {:ok, parent_symbol} <- parent_symbol(symbol),
         parent_module = module |> Module.split() |> Enum.drop(-1) |> Module.concat(),
         true <- message?(parent_module),
         ^parent_symbol <- full_name(parent_module) do
      {parent_symbol, parent_module}
    else
      _ -> nil
    end
  end

  @doc """
  Finds the module for a type declared inside `parent_module`, by its proto name.

  The module is only accepted if its `full_name` says it really is that type, so a module
  that merely has a similar name is never mistaken for it.
  """
  def child_module(parent_module, name) do
    child = Module.concat(parent_module, Macro.camelize(name))

    with true <- message?(parent_module),
         true <- Code.ensure_loaded?(child),
         expected when is_binary(expected) <- full_name(parent_module),
         true <- full_name(child) == expected <> "." <> name do
      {:ok, child}
    else
      _ -> :error
    end
  end

  defp enclosing_message(module) do
    case full_name(module) do
      nil -> nil
      symbol -> parent(symbol, module)
    end
  end

  defp rpc_types(service) do
    for call <- service.__rpc_calls__(),
        {types, _streaming} <- [elem(call, 1), elem(call, 2)],
        do: types
  end

  # a type is reachable through the fields of anything reachable, and its enclosing
  # message is part of the same file
  defp reachable([], seen), do: seen

  defp reachable([module | rest], seen) do
    if MapSet.member?(seen, module) do
      reachable(rest, seen)
    else
      reachable(neighbours(module) ++ rest, MapSet.put(seen, module))
    end
  end

  defp neighbours(module) do
    enclosing =
      case enclosing_message(module) do
        {_symbol, parent_module} -> [parent_module]
        nil -> []
      end

    enclosing ++ field_types(module)
  end

  defp field_types(module) do
    if message?(module) do
      for {_tag, props} <- module.__message_props__().field_props,
          type <- referenced_module(props),
          do: type
    else
      []
    end
  end

  defp referenced_module(%Protobuf.FieldProps{enum?: true, type: {:enum, module}}), do: [module]
  defp referenced_module(%Protobuf.FieldProps{embedded?: true, type: module}), do: [module]
  defp referenced_module(_props), do: []

  defp parent_symbol(symbol) do
    case symbol |> String.split(".") |> Enum.drop(-1) do
      [] -> :error
      parts -> {:ok, Enum.join(parts, ".")}
    end
  end

  defp message?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :__message_props__, 0) and
      not module.__message_props__().enum?
  end

  defp full_name(module) do
    if function_exported?(module, :full_name, 0), do: module.full_name()
  end
end
