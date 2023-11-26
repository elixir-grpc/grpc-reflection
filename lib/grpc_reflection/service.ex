defmodule GrpcReflection.Service do
  @moduledoc false

  use Agent

  require Logger

  alias GrpcReflection.Builder
  alias GrpcReflection.Lookup

  defstruct services: [], files: %{}, symbols: %{}

  @type descriptor_t :: GrpcReflection.descriptor_t()
  @type t :: %{
          required(:services) => list(module()),
          required(:files) => %{optional(binary()) => descriptor_t()},
          required(:symbols) => %{optional(binary()) => descriptor_t()}
        }

  def start_link(_ \\ []) do
    services = Application.get_env(:grpc_reflection, :services, [])

    with %__MODULE__{} = state <- Builder.build_reflection_tree(services) do
      Agent.start_link(fn -> state end, name: __MODULE__)
    else
      err ->
        Logger.error("Failed to build reflection tree: #{inspect(err)}")
        Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)
    end
  end

  @spec list_services :: list(binary)
  def list_services do
    Agent.get(__MODULE__, &Lookup.lookup_services/1)
  end

  @spec get_by_symbol(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_symbol("." <> symbol), do: get_by_symbol(symbol)

  def get_by_symbol(symbol) do
    Agent.get(__MODULE__, &Lookup.lookup_symbol(symbol, &1))
  end

  @spec get_by_filename(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_filename(filename) do
    Agent.get(__MODULE__, &Lookup.lookup_filename(filename, &1))
  end

  @spec put_state(t()) :: :ok
  def put_state(%__MODULE__{} = state) do
    Agent.update(__MODULE__, fn _old_state -> state end)
  end
end
