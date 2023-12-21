defmodule GrpcReflection.DynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(name, services) do
    DynamicSupervisor.start_child(__MODULE__, %{
      id: name,
      start: {GrpcReflection.Service.Agent, :start_link, [[services: services, name: name]]}
    })
  end

  @impl DynamicSupervisor
  def init(init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [init_arg])
  end
end
