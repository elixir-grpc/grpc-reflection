defmodule GrpcReflection.Server do
  @moduledoc """
  A grpc reflection server supports a specific iteration of the reflection protocol

  All versions currently "support" file descriptors by having an encoded proto2 payload as an array of bytes

  ### v1alpha
  The originally proposed specification.  This was around long enough that it has some application support

  ### v1
  The current spec for reflection support within GRPC.
  """

  @type descriptor_t ::
          %Google.Protobuf.DescriptorProto{} | %Google.Protobuf.ServiceDescriptorProto{}

  # credo:disable-for-next-line
  defmacro __using__(opts) when is_list(opts) do
    services = Keyword.get(opts, :services, [])
    version = Keyword.get(opts, :version, :none)

    quote do
      @cfg {__MODULE__, unquote(services)}

      alias GrpcReflection.Service

      @doc """
      Get the current list of configured services
      """
      @spec list_services :: list(binary)
      def list_services do
        Service.list_services(@cfg)
      end

      @doc """
      Get the reflection reponse containing the given symbol, if it is exposed by a configured service
      """
      @spec get_by_symbol(binary()) ::
              {:ok, GrpcReflection.Server.descriptor_t()} | {:error, binary}
      def get_by_symbol(symbol) do
        Service.get_by_symbol(@cfg, symbol)
      end

      @doc """
      Get the reflection response for the named file, if it is exposed by a configured service
      """
      @spec get_by_filename(binary()) ::
              {:ok, GrpcReflection.Server.descriptor_t()} | {:error, binary}
      def get_by_filename(filename) do
        Service.get_by_filename(@cfg, filename)
      end

      @doc """
      Get the extension numbers for the given type, if it is exposed by a configured service
      """
      @spec get_extension_numbers_by_type(binary()) :: {:ok, list(integer())} | {:error, binary}
      def get_extension_numbers_by_type(mod) do
        Service.get_extension_numbers_by_type(@cfg, mod)
      end

      @doc """
      Get the reflection response for the given extension, if it is exposed by a configured service
      """
      @spec get_by_extension(binary()) ::
              {:ok, GrpcReflection.Server.descriptor_t()} | {:error, binary}
      def get_by_extension(containing_type) do
        Service.get_by_extension(@cfg, containing_type)
      end

      @doc """
      A runtime configuration option for setting the services
      """
      @spec put_services(list(module())) :: :ok | {:error, binary()}
      def put_services(services) do
        case Service.build_reflection_tree(services) do
          {:ok, state} -> Service.put_state(@cfg, state)
          err -> err
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
end
