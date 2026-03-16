defmodule GrpcReflection.Service.CycleTest do
  @moduledoc false

  use ExUnit.Case

  alias GrpcReflection.Service.Cycle

  describe "get_cycles" do
    test "should return empty list for empty graph" do
      assert Cycle.find_cycles(%{}) == []
    end

    test "should return empty list when no cycles exist" do
      graph = %{
        "A" => ["B"],
        "B" => ["C"],
        "C" => ["D"]
      }

      assert Cycle.find_cycles(graph) == []
    end

    test "should detect a cycle in a simple cycle A → B → A" do
      graph = %{
        "A" => ["B"],
        "B" => ["A"]
      }

      assert Cycle.find_cycles(graph) == [
               ["A", "B"]
             ]
    end

    test "should detect two distinct cycles" do
      graph = %{
        "A" => ["B"],
        "B" => ["A"],
        "C" => ["D"],
        "D" => ["C"]
      }

      assert Cycle.find_cycles(graph) == [
               ["A", "B"],
               ["C", "D"]
             ]
    end

    test "should detect one cycle in a complex graph" do
      graph = %{
        "A" => ["B", "C"],
        "B" => ["C"],
        "C" => ["D"],
        "D" => ["A"]
      }

      assert Cycle.find_cycles(graph) == [
               ["A", "B", "C", "D"]
             ]
    end

    test "should detect cycle with indirect path" do
      graph = %{
        "A" => ["B"],
        "B" => ["C"],
        "C" => ["D"],
        "D" => ["A"]
      }

      assert Cycle.find_cycles(graph) == [
               ["A", "B", "C", "D"]
             ]
    end

    test "should return empty list for a single node with no edges" do
      graph = %{"A" => []}
      assert Cycle.find_cycles(graph) == []
    end

    test "should ignore nodes with no outgoing edges" do
      graph = %{
        "A" => [],
        "B" => ["C"],
        "C" => ["B"]
      }

      assert Cycle.find_cycles(graph) == [
               ["B", "C"]
             ]
    end

    test "should not duplicate one cycle when referenced multiple times" do
      graph = %{
        "A" => ["C"],
        "B" => ["C"],
        "C" => ["D"],
        "D" => ["C"]
      }

      assert Cycle.find_cycles(graph) == [
               ["C", "D"]
             ]
    end

    test "should handle nodes with many relations" do
      graph = %{
        "A" => ["B", "C", "D", "E"],
        "B" => [],
        "C" => [],
        "D" => [],
        "E" => ["A"]
      }

      assert Cycle.find_cycles(graph) == [
               ["A", "E"]
             ]
    end
  end
end
