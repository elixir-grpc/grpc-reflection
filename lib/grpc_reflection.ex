defmodule GrpcReflection do
  @moduledoc """
  Reflection support for the grpc-elixir package

  To use these servers, all protos must be comppiled with the `gen_descriptors=true` option, as that is the source of truth for the reflection service.

  To turn on reflection in your application, do the following:

  1. Add one or both of the refleciton servers to your grpc endpoing
  ```
  run(GrpcReflection.Server.V1alpha)
  run(GrpcReflection.Server.V1)
  ```

  1. Configure grpc_reflection for the services you want to include in the `list_services` resposne
  ```
  config :grpc_reflection, services: [<Your service module>, <another service module>, <maybe reflection service?>]
  ```

  This service will return reflection data for any module that defined `descriptor()` when its module name is provided, with the following caveat:
  `protoc` using the grpc-elixir plugin will only downcase the first letter for the grpc symbpl  So Helloworld.HelloReply becomes helloworld.HelloReply.  This does not perform a case-insensitive search, but only upcases the first letter of each "."-separated word.  So the provided symbol must match that pattern, and then`descriptor` returns the grpc structs, or no response will be returned
  """

  @type descriptor_t ::
          %Google.Protobuf.DescriptorProto{} | %Google.Protobuf.ServiceDescriptorProto{}

  @spec list_services :: list(binary)
  def list_services do
    if service_running?() do
      GrpcReflection.Service.list_services()
    else
      GrpcReflection.Lookup.lookup_services(%GrpcReflection.Service{
        services: configured_services()
      })
    end
  end

  @spec get_by_symbol(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_symbol(symbol) do
    if service_running?() do
      GrpcReflection.Service.get_by_symbol(symbol)
    else
      %{} = state = GrpcReflection.Builder.build_reflection_tree(configured_services())
      GrpcReflection.Lookup.lookup_symbol(symbol, state)
    end
  end

  @spec get_by_filename(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_filename(filename) do
    if service_running?() do
      GrpcReflection.Service.get_by_filename(filename)
    else
      %{} = state = GrpcReflection.Builder.build_reflection_tree(configured_services())
      GrpcReflection.Lookup.lookup_filename(filename, state)
    end
  end

  @spec put_services(list(module())) :: :ok | {:error, binary()}
  def put_services(services) do
    if service_running?() do
      with %GrpcReflection.Service{} = state <-
             GrpcReflection.Builder.build_reflection_tree(services) do
        GrpcReflection.Service.put_state(state)
      end
    else
      :ok
    end
  end

  defp service_running?, do: is_pid(Process.whereis(GrpcReflection.Service))

  defp configured_services, do: Application.get_env(:grpc_reflection, :services, [])

  @doc false
  def child_spec(opts) do
    %{
      id: GrpcReflection.Service,
      start: {GrpcReflection.Service, :start_link, [opts]},
      type: :worker,
      restart: :permanent
    }
  end
end
