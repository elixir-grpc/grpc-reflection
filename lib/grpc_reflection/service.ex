defmodule GrpcReflection.Service do
  @moduledoc """
  Primary interface to internal reflection state and logic
  """

  alias GrpcReflection.Service.Agent
  alias GrpcReflection.Service.Builder

  defdelegate build_reflection_tree(services), to: Builder

  defdelegate put_state(cfg, state), to: Agent

  defdelegate list_services(cfg), to: Agent
  defdelegate get_by_symbol(cfg, symbol), to: Agent
  defdelegate get_by_filename(cfg, filename), to: Agent
  defdelegate get_by_extension(cfg, containing_type), to: Agent
  defdelegate get_extension_numbers_by_type(cfg, mod), to: Agent
end
