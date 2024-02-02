defmodule GrpcReflection.Service.Agent do
  @moduledoc false

  use Agent

  require Logger

  alias GrpcReflection.Service.Builder
  alias GrpcReflection.Service.State

  @type cfg_t :: {atom(), list(atom)}

  def start_link(_, opts) do
    name = Keyword.get(opts, :name)
    services = Keyword.get(opts, :services)

    case Builder.build_reflection_tree(services) do
      {:ok, state} ->
        Agent.start_link(fn -> state end, name: name)

      err ->
        Logger.error("Failed to build reflection tree: #{inspect(err)}")
        Agent.start_link(fn -> %State{} end, name: name)
    end
  end

  @spec list_services(cfg_t()) :: list(binary)
  def list_services(cfg) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &State.lookup_services/1)
  end

  @spec get_by_symbol(cfg_t(), binary()) :: {:ok, State.descriptor_t()} | {:error, binary}
  def get_by_symbol(cfg, symbol) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &State.lookup_symbol(symbol, &1))
  end

  @spec get_by_filename(cfg_t(), binary()) :: {:ok, State.descriptor_t()} | {:error, binary}
  def get_by_filename(cfg, filename) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &State.lookup_filename(filename, &1))
  end

  @spec get_by_extension(cfg_t(), binary()) :: {:ok, State.descriptor_t()} | {:error, binary}
  def get_by_extension(cfg, containing_type) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &State.lookup_extension(containing_type, &1))
  end

  @spec get_extension_numbers_by_type(cfg_t(), binary()) ::
          {:ok, list(integer())} | {:error, binary}
  def get_extension_numbers_by_type(cfg, mod) do
    name = start_agent_on_first_call(cfg)
    Agent.get(name, &State.lookup_extension_numbers(mod, &1))
  end

  @spec put_state(cfg_t(), State.t()) :: :ok
  def put_state(cfg, %State{} = state) do
    name = start_agent_on_first_call(cfg)
    Agent.update(name, fn _old_state -> state end)
  end

  defp start_agent_on_first_call({name, services}) do
    # lazy start agent on call
    case GrpcReflection.DynamicSupervisor.start_child(name, services) do
      {:ok, _} -> Logger.info("Started reflection agent #{name}")
      {:error, {:already_started, _}} -> :ok
    end

    name
  end
end
