defmodule GrpcReflection.Service do
  @moduledoc """
  A supervise-able memory store that holds and manages data for grpc reflection
  """

  use Agent

  require Logger

  defstruct services: [], files: %{}, symbols: %{}

  @type descriptor_t :: GrpcReflection.descriptor_t()

  def start_link(_ \\ []) do
    services = Application.get_env(:grpc_reflection, :services, [])

    with :ok <- validate_services(services),
         %__MODULE__{} = state <- build_reflection_tree(services) do
      Agent.start_link(fn -> state end, name: __MODULE__)
    else
      err ->
        Logger.error("Failed to build reflection tree: #{inspect(err)}")
        Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)
    end
  end

  @spec list_services :: list(binary)
  def list_services do
    Agent.get(__MODULE__, fn %{services: services} ->
      Enum.map(services, fn service_mod -> service_mod.__meta__(:name) end)
    end)
  end

  @spec get_by_symbol(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_symbol("." <> symbol), do: get_by_symbol(symbol)

  def get_by_symbol(symbol) do
    Agent.get(__MODULE__, fn %{symbols: symbols} ->
      if Map.has_key?(symbols, symbol) do
        {:ok, symbols[symbol]}
      else
        {:error, "symbol not found"}
      end
    end)
  end

  @spec get_by_filename(binary()) :: {:ok, descriptor_t()} | {:error, binary}
  def get_by_filename(filename) do
    Agent.get(__MODULE__, fn %{files: files} ->
      if Map.has_key?(files, filename) do
        {:ok, files[filename]}
      else
        {:error, "filename not found"}
      end
    end)
  end

  @spec put_services(list(module())) :: :ok | {:error, binary()}
  def put_services(services) do
    with :ok <- validate_services(services),
         %__MODULE__{} = state <- build_reflection_tree(services) do
      Agent.update(__MODULE__, fn _old_state -> state end)
    end
  end

  defp validate_services(services) do
    services
    |> Enum.reject(fn service_mod ->
      is_binary(service_mod.__meta__(:name)) and is_struct(service_mod.descriptor())
    end)
    |> then(fn
      [] -> :ok
      _ -> {:error, "non-service module provided"}
    end)
  rescue
    _ -> {:error, "non-service module provided"}
  end

  defp build_reflection_tree(services) do
    with {%{files: _, symbols: _} = data, references} <- get_services_and_references(services) do
      references
      |> List.flatten()
      |> Enum.uniq()
      |> process_references(data)
    end
  end

  defp get_services_and_references(services) do
    Enum.reduce_while(services, {%__MODULE__{services: services}, []}, fn service, {acc, refs} ->
      with {:ok, %{files: files, symbols: symbols}, references} <- process_service(service) do
        {:cont,
         {%{acc | files: Map.merge(files, acc.files), symbols: Map.merge(symbols, acc.symbols)},
          [refs | references]}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp process_service(service) do
    descriptor = service.descriptor()
    service_name = service.__meta__(:name)
    referenced_types = types_from_descriptor(descriptor)

    method_symbols =
      Enum.map(
        descriptor.method,
        fn method -> service_name <> "." <> method.name end
      )

    unencoded_payload = process_common(service_name, descriptor)
    payload = Google.Protobuf.FileDescriptorProto.encode(unencoded_payload)
    response = %{file_descriptor_proto: [payload]}

    root_symbols =
      method_symbols
      |> Enum.reduce(%{}, fn name, acc -> Map.put(acc, name, response) end)
      |> Map.put(service_name, response)

    root_files = %{(service_name <> ".proto") => response}

    {:ok, %__MODULE__{files: root_files, symbols: root_symbols}, referenced_types}
  rescue
    _ -> {:error, "Couldn't process #{inspect(service)}"}
  end

  defp process_references([], data), do: data

  defp process_references([reference | rest], data) do
    if Map.has_key?(data.symbols, reference) do
      process_references(rest, data)
    else
      {%{files: f, symbols: s}, references} = process_reference(reference)
      data = %{data | files: Map.merge(data.files, f), symbols: Map.merge(data.symbols, s)}
      references = (rest ++ references) |> List.flatten() |> Enum.uniq()
      process_references(references, data)
    end
  end

  defp process_reference(symbol) do
    symbol
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn
      [m | segments] -> [m | Enum.map(segments, &upcase_first/1)]
    end)
    |> Enum.reverse()
    |> Enum.join(".")
    |> then(fn name -> "Elixir." <> name end)
    |> String.to_existing_atom()
    |> then(fn mod ->
      descriptor = mod.descriptor()
      name = symbol

      referenced_types = types_from_descriptor(descriptor)
      unencoded_payload = process_common(name, descriptor)
      payload = Google.Protobuf.FileDescriptorProto.encode(unencoded_payload)
      response = %{file_descriptor_proto: [payload]}

      root_symbols = %{symbol => response}
      root_files = %{(symbol <> ".proto") => response}

      {%__MODULE__{files: root_files, symbols: root_symbols}, referenced_types}
    end)
  end

  defp process_common(name, descriptor) do
    package = package_from_name(name)

    dependencies =
      descriptor
      |> types_from_descriptor()
      |> Enum.map(fn name ->
        name <> ".proto"
      end)

    response_stub = %Google.Protobuf.FileDescriptorProto{
      name: name <> ".proto",
      package: package,
      dependency: dependencies
    }

    case descriptor do
      %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
      %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
    end
  end

  defp types_from_descriptor(%Google.Protobuf.ServiceDescriptorProto{} = descriptor) do
    descriptor.method
    |> Enum.flat_map(fn method ->
      [method.input_type, method.output_type]
    end)
    |> Enum.reject(&is_atom/1)
    |> Enum.map(fn
      "." <> symbol -> symbol
      symbol -> symbol
    end)
  end

  defp types_from_descriptor(%Google.Protobuf.DescriptorProto{} = descriptor) do
    descriptor.field
    |> Enum.map(fn field ->
      field.type_name
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn
      "." <> symbol -> symbol
      symbol -> symbol
    end)
  end

  defp package_from_name(service_name) do
    service_name
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn [_ | rest] -> rest end)
    |> Enum.reverse()
    |> Enum.join(".")
  end

  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest
end
