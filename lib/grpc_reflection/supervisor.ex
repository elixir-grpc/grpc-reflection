defmodule GrpcReflection.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    children = [
      %{
        id: OneOffTask,
        start: {Task, :start_link, [__MODULE__, :one_off_task, []]},
        type: :worker,
        restart: :temporary
      },
      %{
        id: GrpcReflection.DynamicSupervisor,
        start: {GrpcReflection.DynamicSupervisor, :start_link, [opts]},
        type: :supervisor,
        restart: :permanent
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc false
  def one_off_task do
    Protobuf.load_extensions()
    :ignore
  end
end
