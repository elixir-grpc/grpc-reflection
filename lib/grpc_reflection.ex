defmodule GrpcReflection do
  @moduledoc """
  Reflection support for the grpc-elixir package

  To use these servers, all protos must be compiled with the `gen_descriptors=true` option, as that is the source of truth for the reflection service.

  To turn on reflection in your application, do the following:

  1. Create your reflection server
  ```elixir
  defmodule Helloworld.Reflection.Server do
    use GrpcReflection,
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

  @type descriptor_t ::
          %Google.Protobuf.DescriptorProto{} | %Google.Protobuf.ServiceDescriptorProto{}

  # credo:disable-for-next-line
  defmacro __using__(opts) when is_list(opts) do
    services = Keyword.get(opts, :services, [])
    version = Keyword.get(opts, :version, :none)

    quote do
      @cfg {__MODULE__, unquote(services)}

      @doc """
      Get the current list of configured services
      """
      @spec list_services :: list(binary)
      def list_services do
        GrpcReflection.Service.Agent.list_services(@cfg)
      end

      @doc """
      Get the reflection reponse containing the given symbol, if it is exposed by a configured service
      """
      @spec get_by_symbol(binary()) :: {:ok, GrpcReflection.descriptor_t()} | {:error, binary}
      def get_by_symbol(symbol) do
        GrpcReflection.Service.Agent.get_by_symbol(@cfg, symbol)
      end

      @doc """
      Get the reflection response for the named file, if it is exposed by a configured service
      """
      @spec get_by_filename(binary()) :: {:ok, GrpcReflection.descriptor_t()} | {:error, binary}
      def get_by_filename(filename) do
        GrpcReflection.Service.Agent.get_by_filename(@cfg, filename)
      end

      @doc """
      A runtime configuration option for setting the services
      """
      @spec put_services(list(module())) :: :ok | {:error, binary()}
      def put_services(services) do
        case GrpcReflection.Service.Builder.build_reflection_tree(services) do
          %GrpcReflection.Service.Agent{} = state ->
            GrpcReflection.Service.Agent.put_state(@cfg, state)

          err ->
            err
        end
      end

      case unquote(version) do
        :v1 ->
          use GRPC.Server, service: Grpc.Reflection.V1.ServerReflection.Service

          def server_reflection_info(request_stream, server) do
            GrpcReflection.Server.V1.server_reflection_info(
              __MODULE__,
              request_stream,
              server
            )
          end

        :v1alpha ->
          use GRPC.Server, service: Grpc.Reflection.V1alpha.ServerReflection.Service

          def server_reflection_info(request_stream, server) do
            GrpcReflection.Server.V1alpha.server_reflection_info(
              __MODULE__,
              request_stream,
              server
            )
          end

        _ ->
          raise "Invalid version #{unquote(version)}, should be in [:v1, :v1alpha]"
      end
    end
  end

  @doc false
  def child_spec(opts) do
    %{
      id: GrpcReflection.DynamicSupervisor,
      start: {GrpcReflection.DynamicSupervisor, :start_link, [opts]},
      type: :supervisor,
      restart: :permanent
    }
  end
end
