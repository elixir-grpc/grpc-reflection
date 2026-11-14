defmodule GrpcReflection.Service.Builder.Repair do
  @moduledoc false

  # A nested type is traced when something refers to it, through the module that refers to
  # it, or else by looking for its module by name. If neither works we have a nested type
  # nothing reachable refers to, whose own references were never followed. Serving it would
  # make its file import files we never built, and a client cannot load such a file.
  #
  # Nothing reachable uses that nested type, so leaving it out of its file changes nothing a
  # client can get to, and keeps the rest of the file loadable.

  alias GrpcReflection.Service.Builder.Util
  alias GrpcReflection.Service.State

  require Logger

  def drop_unresolvable_nested(%State{files: files} = state) do
    Enum.reduce(Enum.sort(files), state, fn {filename, file}, state ->
      repair_file(state, filename, file)
    end)
  end

  defp repair_file(state, filename, %{message_type: [message]} = file) do
    symbol = qualify(file.package, message.name)

    case prune(message, symbol, state) do
      {_message, []} ->
        state

      {pruned, dropped} ->
        repaired = %{
          file
          | message_type: [pruned],
            dependency: Util.dependencies(symbol, pruned)
        }

        dropped
        |> Enum.each(fn {nested_symbol, _nested, unresolved} ->
          Logger.warning(
            "reflection left out nested type #{nested_symbol} of #{filename}: no module " <>
              "for it was found, and it refers to #{Enum.join(unresolved, ", ")}, which " <>
              "was never traced"
          )
        end)

        %{
          state
          | files: Map.put(state.files, filename, repaired),
            symbols: Map.drop(state.symbols, dropped_symbols(dropped))
        }
    end
  end

  defp repair_file(state, _filename, _file), do: state

  # returns the message without its droppable nested messages, and what was dropped
  defp prune(message, symbol, state) do
    {kept, dropped} =
      Enum.reduce(message.nested_type, {[], []}, fn nested, {kept, dropped} ->
        nested_symbol = symbol <> "." <> nested.name

        case droppable(nested, nested_symbol, state) do
          {:drop, unresolved} ->
            {kept, [{nested_symbol, nested, unresolved} | dropped]}

          :keep ->
            {pruned, deeper} = prune(nested, nested_symbol, state)
            {[pruned | kept], deeper ++ dropped}
        end
      end)

    {%{message | nested_type: Enum.reverse(kept)}, dropped}
  end

  defp droppable(nested, nested_symbol, state) do
    with [_ | _] = unresolved <- unresolved_references(nested, nested_symbol, state),
         true <- untraced?(nested, nested_symbol, state) do
      {:drop, unresolved}
    else
      _ -> :keep
    end
  end

  # neither it nor anything nested inside it was traced
  defp untraced?(nested, nested_symbol, state) do
    symbols = [nested_symbol | Util.get_nested_types(nested_symbol, nested)]
    not Enum.any?(symbols, &MapSet.member?(state.traced, &1))
  end

  defp unresolved_references(nested, nested_symbol, state) do
    nested
    |> Util.types_from_descriptor()
    |> Enum.uniq()
    |> Enum.reject(&(is_map_key(state.symbols, &1) or &1 in own_symbols(nested, nested_symbol)))
  end

  defp own_symbols(nested, nested_symbol),
    do: [nested_symbol | Util.get_nested_types(nested_symbol, nested)]

  defp dropped_symbols(dropped) do
    Enum.flat_map(dropped, fn {nested_symbol, nested, _unresolved} ->
      own_symbols(nested, nested_symbol)
    end)
  end

  defp qualify("", name), do: name
  defp qualify(package, name), do: package <> "." <> name
end
