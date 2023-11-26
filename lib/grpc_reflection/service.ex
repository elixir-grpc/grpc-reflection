defmodule GrpcReflection.Service do
  @moduledoc """
  A supervise-able memory store that holds and manages data for grpc reflection
  """

  use Agent

  require Logger

  alias GrpcReflection.Builder

  defstruct services: [], files: %{}, symbols: %{}

  @type descriptor_t :: GrpcReflection.descriptor_t()

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
    Agent.get(__MODULE__, fn %{services: services} ->
      Enum.map(services, fn service_mod -> service_mod.__meta__(:name) end)
    end)
  end

  @spec get_by_symbol(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_symbol("." <> symbol), do: get_by_symbol(symbol)

  def get_by_symbol(symbol) do
    Agent.get(__MODULE__, fn %{symbols: symbols} ->
      if Map.has_key?(symbols, symbol) do
        {:ok, symbols[symbol]}
      else
        {:error, "symbol not found"}
      end
    end)
  end

  @spec get_by_filename(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_filename(filename) do
    Agent.get(__MODULE__, fn %{files: files} ->
      if Map.has_key?(files, filename) do
        {:ok, files[filename]}
      else
        {:error, "filename not found"}
      end
    end)
  end

  @spec put_services(list(module())) :: :ok | {:error, binary()}
  def put_services(services) do
    with %__MODULE__{} = state <- Builder.build_reflection_tree(services) do
      Agent.update(__MODULE__, fn _old_state -> state end)
    end
  end
end
