defmodule GrpcReflection do
  @moduledoc """
  Reflection support for the grpc-elixir package

  Protos compiled with `gen_descriptors=true` provide the richest reflection output.
  If that option is omitted, this library synthesizes descriptors from runtime module
  metadata (`__message_props__`, `__rpc_calls__`). The synthesized path produces
  equivalent output for standard gRPC reflection clients; only proto2 extensions and
  custom proto options are unavailable without `gen_descriptors=true`.

  To turn on reflection in your application, do the following:

  1. Create your reflection server
  ```elixir
  defmodule Helloworld.Reflection.Server do
    use GrpcReflection.Server,
      version: :v1,
      services: [Helloworld.Greeter.Service]
  end
  ```

  2. Add the reflection supervisor to your supervision tree
  ```elixir
  children = [
    {GRPC.Server.Supervisor, endpoint: Helloworld.Endpoint, port: 50051, start_server: true},
    GrpcReflection
  ]
  ```

  3. Add your reflection server to your endpoint
  ```elixir
  defmodule Helloworld.Endpoint do
    use GRPC.Endpoint

    intercept(GRPC.Server.Interceptors.Logger)
    run(Helloworld.Greeter.Server)
    run(Helloworld.Reflection.Server)
  end
  ```
  """

  require Logger

  defmacro __using__(opts) when is_list(opts) do
    Logger.warning("""
    `use GrpcReflection` is deprecated.
    Please replace with `use GrpcReflection.Server` instead
    """)

    quote do
      use GrpcReflection.Server, unquote(opts)
    end
  end

  @doc false
  def child_spec(opts) do
    %{
      id: GrpcReflection,
      start: {GrpcReflection.Supervisor, :start_link, [opts]},
      type: :supervisor,
      restart: :permanent
    }
  end
end
