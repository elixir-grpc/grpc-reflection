defmodule GrpcReflection.TestClient do
  use ExUnit.CaseTemplate
  import GrpcCase

  defmacro __using__(version: version) do
    endpoint = GrpcReflection.TestEndpoint.Endpoint

    quote do
      setup_all do
        Protobuf.load_extensions()

        {:ok, _pid, port} = GRPC.Server.start_endpoint(unquote(endpoint), 0)
        on_exit(fn -> :ok = GRPC.Server.stop_endpoint(unquote(endpoint), []) end)
        start_supervised({GRPC.Client.Supervisor, []})

        host = "localhost:#{port}"
        {:ok, channel} = GRPC.Stub.connect(host)

        req =
          case unquote(version) do
            :v1 -> %Grpc.Reflection.V1.ServerReflectionRequest{host: host}
            :v1alpha -> %Grpc.Reflection.V1alpha.ServerReflectionRequest{host: host}
          end

        stub =
          case unquote(version) do
            :v1 -> GrpcReflection.TestEndpoint.V1Server.Stub
            :v1alpha -> GrpcReflection.TestEndpoint.V1AlphaServer.Stub
          end

        %{channel: channel, req: req, stub: stub, version: unquote(version)}
      end
    end
  end

  def traverse_service(ctx) do
    Stream.unfold([{:list_services, ""}], fn
      [] ->
        nil

      [{:list_services, ""} = message | rest] = term ->
        # add commands to get the files for the listed services
        {:ok, %{service: service_list}} = run_request(message, ctx)

        commands =
          Enum.map(service_list, fn %{name: service_name} ->
            {:file_containing_symbol, service_name}
          end)

        {term, commands ++ rest}

      [{:file_by_filename, _} = message | rest] = term ->
        message
        |> run_request(ctx)
        |> case do
          {:ok, descriptor} ->
            commands = links_from_descriptor(descriptor, ctx)
            {term, commands ++ rest}
        end

      [{:file_containing_extension, _} = message | rest] = term ->
        message
        |> run_request(ctx)
        |> case do
          {:ok, _descriptor} ->
            # extensions depend on the base type
            # if we load the dependencies and feed it into the unfold action
            # we get stuck in a loop
            {term, rest}

          {:error, %{error_message: "extension not found"}} ->
            {term, rest}
        end

      [{:file_containing_symbol, _} = message | rest] = term ->
        # get the file containing the symbol, and add commands to get the dependencies
        message
        |> run_request(ctx)
        |> case do
          {:ok, descriptor} ->
            commands = links_from_descriptor(descriptor, ctx)
            {term, commands ++ rest}
        end
    end)
    |> Enum.to_list()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp links_from_descriptor(%Google.Protobuf.FileDescriptorProto{} = proto, ctx) do
    file_dependencies(proto) ++
      service_dependencies(proto) ++
      extension_dependencies(proto, ctx)
  end

  defp file_dependencies(%Google.Protobuf.FileDescriptorProto{dependency: dependencies}) do
    Enum.map(dependencies, fn dep_file ->
      {:file_by_filename, dep_file}
    end)
  end

  defp service_dependencies(%Google.Protobuf.FileDescriptorProto{service: services}) do
    Enum.flat_map(services, fn %{method: methods} ->
      Enum.flat_map(methods, fn
        %{input_type: input, output_type: output} ->
          [{:file_containing_symbol, input}, {:file_containing_symbol, output}]
      end)
    end)
  end

  defp extension_dependencies(
         %Google.Protobuf.FileDescriptorProto{
           package: package,
           message_type: types
         },
         %{version: version}
       ) do
    request_mod =
      case version do
        :v1 -> Grpc.Reflection.V1.ExtensionRequest
        :v1alpha -> Grpc.Reflection.V1alpha.ExtensionRequest
      end

    gen_range = fn
      extendee, ranges ->
        ranges
        |> Enum.flat_map(fn %{start: start, end: finish} -> start..finish//1 end)
        |> Enum.map(fn num ->
          {:file_containing_extension,
           struct(request_mod, %{
             containing_type: extendee,
             extension_number: num
           })}
        end)
    end

    Enum.flat_map(types, fn type ->
      extendee = package <> "." <> type.name
      extendee_commands = gen_range.(extendee, type.extension_range)

      nested_commands =
        Enum.flat_map(type.nested_type, fn nested_type ->
          extendee = extendee <> "." <> nested_type.name
          gen_range.(extendee, type.extension_range)
        end)

      extendee_commands ++ nested_commands
    end)
  end
end
