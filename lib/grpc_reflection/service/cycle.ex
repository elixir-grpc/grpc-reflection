defmodule GrpcReflection.Service.Cycle do
  @moduledoc """
  Find and identify cycles in a state graph
  """

  defmodule DFS do
    @moduledoc false
    defstruct visited: [], path: [], cycles: []
  end

  def get_cycles(%GrpcReflection.Service.State{files: files}) do
    files
    |> Map.values()
    |> Enum.reject(fn file ->
      String.ends_with?(file.name, "Extension.proto")
    end)
    |> Map.new(fn file -> {file.name, file.dependency} end)
    |> find_cycles()
  end

  def find_cycles(graph) do
    graph
    |> Map.keys()
    |> Enum.reduce(%DFS{}, fn node, acc ->
      %{
        dfs(node, graph, acc)
        | path: acc.path
      }
    end)
    |> Map.fetch!(:cycles)
    |> Enum.map(&Enum.sort/1)
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp dfs(node, graph, state) do
    cond do
      Enum.member?(state.path, node) ->
        # Node is in current path → cycle found
        cycle = [node | Enum.take_while(state.path, &(&1 != node))]
        %{state | cycles: [cycle | state.cycles]}

      Enum.member?(state.visited, node) ->
        state

      true ->
        # Mark as visited and extend path
        state = %{
          state
          | visited: [node | state.visited],
            path: [node | state.path]
        }

        # Visit neighbors
        graph
        |> Map.get(node, [])
        |> Enum.reduce(state, fn neighbor, acc ->
          %{
            dfs(neighbor, graph, acc)
            | path: acc.path
          }
        end)
    end
  end
end
