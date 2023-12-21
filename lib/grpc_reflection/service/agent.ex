defmodule GrpcReflection.Service.Agent do
  @moduledoc false

  use Agent

  require Logger

  alias GrpcReflection.Service.Builder
  alias GrpcReflection.Service.Lookup

  defstruct services: [], files: %{}, symbols: %{}, extensions: %{}

  @type descriptor_t :: GrpcReflection.descriptor_t()
  @type t :: %{
          required(:services) => list(module()),
          required(:files) => %{optional(binary()) => descriptor_t()},
          required(:symbols) => %{optional(binary()) => descriptor_t()},
          required(:extensions) => %{optional(binary()) => list(integer())}
        }

  def start_link(_, opts) do
    Protobuf.load_extensions()
    name = Keyword.get(opts, :name)
    services = Keyword.get(opts, :services)

    case Builder.build_reflection_tree(services) do
      %__MODULE__{} = state ->
        Agent.start_link(fn -> state end, name: name)

      err ->
        Logger.error("Failed to build reflection tree: #{inspect(err)}")
        Agent.start_link(fn -> %__MODULE__{} end, name: name)
    end
  end

  @spec list_services(atom()) :: list(binary)
  def list_services(cfg) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &Lookup.lookup_services/1)
  end

  @spec get_by_symbol(atom(), binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_symbol(cfg, symbol) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &Lookup.lookup_symbol(symbol, &1))
  end

  @spec get_by_filename(atom(), binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_filename(cfg, filename) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &Lookup.lookup_filename(filename, &1))
  end

  @spec get_by_extension(atom(), binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_extension(cfg, containing_type) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &Lookup.lookup_extension(containing_type, &1))
  end

  @spec get_extension_numbers_by_type(atom(), binary()) ::
          {:ok, list(integer())} | {:error, binary}
  def get_extension_numbers_by_type(cfg, mod) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &Lookup.lookup_extension_numbers(mod, &1))
  end

  def put_state(cfg, %__MODULE__{} = state) do
    name = start_agent_on_first_call(cfg)
    Agent.update(name, fn _old_state -> state end)
  end

  defp start_agent_on_first_call({name, services}) do
    # lazy start agent on call
    if match?({:ok, _}, GrpcReflection.DynamicSupervisor.start_child(name, services)) do
      Logger.info("Started reflection agent #{name}")
    end

    name
  end
end
