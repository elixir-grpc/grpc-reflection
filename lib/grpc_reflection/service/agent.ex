defmodule GrpcReflection.Service.Agent do
  @moduledoc false

  use Agent

  require Logger

  alias GrpcReflection.Service.Builder
  alias GrpcReflection.Service.Lookup

  defstruct services: [], files: %{}, symbols: %{}

  @type descriptor_t :: GrpcReflection.descriptor_t()
  @type t :: %{
          required(:services) => list(module()),
          required(:files) => %{optional(binary()) => descriptor_t()},
          required(:symbols) => %{optional(binary()) => descriptor_t()}
        }

  def start_link(options) do
    services = Keyword.get(options, :services, [])
    name = Keyword.get(options, :name, __MODULE__)

    case Builder.build_reflection_tree(services) do
      %__MODULE__{} = state ->
        Agent.start_link(fn -> state end, name: name)

      err ->
        Logger.error("Failed to build reflection tree: #{inspect(err)}")
        Agent.start_link(fn -> %__MODULE__{} end, name: name)
    end
  end

  @spec list_services(atom()) :: list(binary)
  def list_services(name) do
    Agent.get(name, &Lookup.lookup_services/1)
  end

  @spec get_by_symbol(atom(), binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_symbol(name, symbol) do
    Agent.get(name, &Lookup.lookup_symbol(symbol, &1))
  end

  @spec get_by_filename(atom(), binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_filename(name, filename) do
    Agent.get(name, &Lookup.lookup_filename(filename, &1))
  end

  def put_state(name, %__MODULE__{} = state) do
    Agent.update(name, fn _old_state -> state end)
  end
end
