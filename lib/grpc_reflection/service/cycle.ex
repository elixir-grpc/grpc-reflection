defmodule GrpcReflection.Service.Cycle do
  @moduledoc false

  def get_cycles(%GrpcReflection.Service.State{files: files}) do
    files
    |> Map.values()
    |> Enum.reject(&String.ends_with?(&1.name, "Extension.proto"))
    |> Map.new(fn file -> {file.name, file.dependency} end)
    |> find_cycles()
  end

  defp find_cycles(graph) do
    graph
    |> Map.keys()
    |> Enum.reduce({[], []}, fn node, {visited, cycles} ->
      dfs(node, graph, visited, [], cycles)
    end)
    |> elem(1)
    |> Enum.map(&Enum.sort/1)
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp dfs(node, graph, visited, path, cycles) do
    cond do
      node in path ->
        cycle = [node | Enum.take_while(path, &(&1 != node))]
        {visited, [cycle | cycles]}

      node in visited ->
        {visited, cycles}

      true ->
        {visited, cycles} =
          graph
          |> Map.get(node, [])
          |> Enum.reduce({[node | visited], cycles}, fn neighbor, {v, c} ->
            dfs(neighbor, graph, v, [node | path], c)
          end)

        {visited, cycles}
    end
  end
end
