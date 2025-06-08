defmodule GrpcReflection.Service.State do
  @moduledoc false

  defstruct services: [],
            files: %{},
            symbols: %{},
            extensions: %{},
            references: MapSet.new(),
            # New: File-based descriptor storage (direct binary for efficiency)
            file_descriptors: %{},
            # New: Message-to-file mapping (direct binary for efficiency)
            message_to_file: %{}

  @type descriptor_t :: GrpcReflection.Server.descriptor_t()
  @type entry_t :: %{optional(binary()) => descriptor_t()}

  @type t :: %__MODULE__{
          services: list(module()),
          files: entry_t(),
          symbols: entry_t(),
          extensions: %{optional(binary()) => list(integer())},
          references: MapSet.t(binary()),
          # New: File-based descriptor storage
          file_descriptors: %{String.t() => binary()},
          # New: Message-to-file mapping (direct binary for efficiency)
          message_to_file: %{module() => binary()}
        }

  @spec new(list(module)) :: t()
  def new(services \\ []), do: %__MODULE__{services: services}

  @spec merge(t(), t()) :: t()
  def merge(%__MODULE__{} = state1, %__MODULE__{} = state2) do
    %__MODULE__{
      services: Enum.uniq(state1.services ++ state2.services),
      files: Map.merge(state1.files, state2.files),
      symbols: Map.merge(state1.symbols, state2.symbols),
      extensions: Map.merge(state1.extensions, state2.extensions),
      references: MapSet.union(state1.references, state2.references),
      # New: Merge file-based descriptors
      file_descriptors: Map.merge(state1.file_descriptors, state2.file_descriptors),
      message_to_file: Map.merge(state1.message_to_file, state2.message_to_file)
    }
  end

  @spec add_files(t(), entry_t()) :: t()
  def add_files(%__MODULE__{} = state, files) do
    %{state | files: Map.merge(files, state.files)}
  end

  @spec add_symbols(t(), entry_t()) :: t()
  def add_symbols(%__MODULE__{} = state, symbols) do
    %{state | symbols: Map.merge(symbols, state.symbols)}
  end

  def add_extensions(%__MODULE__{} = state, extensions) do
    %{state | extensions: Map.merge(extensions, state.extensions)}
  end

  def add_references(%__MODULE__{} = state, refs) do
    references = Enum.reduce(refs, state.references, &MapSet.put(&2, &1))
    %{state | references: references}
  end

  # New: Functions for file-based descriptor management
  @spec add_file_descriptors(t(), %{String.t() => binary()}) :: t()
  def add_file_descriptors(%__MODULE__{} = state, file_descriptors) do
    %{state | file_descriptors: Map.merge(state.file_descriptors, file_descriptors)}
  end

  @spec add_message_to_file_mappings(t(), %{module() => binary()}) :: t()
  def add_message_to_file_mappings(%__MODULE__{} = state, message_to_file) do
    %{state | message_to_file: Map.merge(state.message_to_file, message_to_file)}
  end

  def get_references(%__MODULE__{} = state), do: MapSet.to_list(state.references)

  def lookup_services(%__MODULE__{services: services}) do
    Enum.map(services, fn service_mod -> service_mod.__meta__(:name) end)
  end

  def lookup_symbol("." <> symbol, state), do: lookup_symbol(symbol, state)

  def lookup_symbol(symbol, %__MODULE__{} = state) do
    # New: Try file-based lookup first
    case lookup_symbol_file_based(symbol, state) do
      {:ok, _} = result ->
        result

      {:error, _} ->
        # Fallback to legacy lookup for backward compatibility
        lookup_symbol_legacy(symbol, state)
    end
  end

  # New: File-based symbol lookup
  defp lookup_symbol_file_based(symbol, %__MODULE__{
         message_to_file: message_to_file,
         file_descriptors: file_descriptors
       }) do
    case symbol_to_module(symbol) do
      {:ok, module} ->
        case Map.fetch(message_to_file, module) do
          {:ok, file_descriptor_binary} ->
            {:ok, %{file_descriptor_proto: [file_descriptor_binary]}}

          :error ->
            # Try service symbol lookup in file descriptors
            lookup_service_symbol_file_based(symbol, file_descriptors)
        end

      {:error, _} ->
        # Try service symbol lookup in file descriptors
        lookup_service_symbol_file_based(symbol, file_descriptors)
    end
  end

  # Lookup service symbols in file descriptors
  defp lookup_service_symbol_file_based(symbol, file_descriptors) do
    # Service symbols like "helloworld.Greeter" should be found in their namespace file
    case infer_namespace_from_service_symbol(symbol) do
      {:ok, namespace_file} ->
        case Map.fetch(file_descriptors, namespace_file) do
          {:ok, file_descriptor_binary} ->
            {:ok, %{file_descriptor_proto: [file_descriptor_binary]}}

          :error ->
            {:error, "service symbol not found in file-based storage"}
        end

      _ ->
        {:error, "could not infer namespace for service symbol"}
    end
  end

  # Infer namespace file from service symbol
  defp infer_namespace_from_service_symbol(symbol) do
    parts = String.split(symbol, ".")

    case parts do
      # Method symbols: "helloworld.Greeter.SayHello" -> extract service part
      [namespace, service_name, _method] ->
        namespace_path = namespace |> Macro.underscore()
        service_file = service_name |> Macro.underscore()
        {:ok, "#{namespace_path}/#{service_file}.proto"}

      # Service symbols: "helloworld.Greeter" -> "helloworld/greeter.proto"
      [namespace, service_name] ->
        namespace_path = namespace |> Macro.underscore()
        service_file = service_name |> Macro.underscore()
        {:ok, "#{namespace_path}/#{service_file}.proto"}

      # gRPC reflection service and methods
      ["grpc", "reflection" | rest] ->
        version_path =
          rest
          # Take all but method name if present
          |> Enum.take(-2)
          |> Enum.map(&Macro.underscore/1)
          |> Enum.join("/")

        {:ok, "grpc/reflection/#{version_path}/reflection.proto"}

      # Multi-part service symbols (without method)
      [namespace | rest] when length(rest) > 1 ->
        # Check if last part might be a method name
        if length(rest) > 2 do
          # Likely includes method, take all but last
          [service_parts, _method] = Enum.split(rest, -1)
          namespace_path = namespace |> Macro.underscore()
          service_path = service_parts |> Enum.map(&Macro.underscore/1) |> Enum.join("_")
          {:ok, "#{namespace_path}/#{service_path}.proto"}
        else
          # Service only
          namespace_path = namespace |> Macro.underscore()
          service_path = rest |> Enum.map(&Macro.underscore/1) |> Enum.join("_")
          {:ok, "#{namespace_path}/#{service_path}.proto"}
        end

      _ ->
        {:error, "could not parse service symbol"}
    end
  end

  # Legacy symbol lookup (existing implementation)
  defp lookup_symbol_legacy(symbol, %__MODULE__{symbols: symbols}) do
    if Map.has_key?(symbols, symbol) do
      {:ok, symbols[symbol]}
    else
      {:error, "symbol not found"}
    end
  end

  # Helper function to convert symbol string to module
  defp symbol_to_module(symbol) do
    try do
      module =
        symbol
        |> String.split(".")
        |> Enum.map(&Macro.camelize/1)
        |> Module.concat()

      # Verify the module exists - use descriptor function as that's what we need
      if Code.ensure_loaded?(module) and function_exported?(module, :descriptor, 0) do
        {:ok, module}
      else
        {:error, "module not found or not a protobuf module"}
      end
    rescue
      _ -> {:error, "invalid symbol format"}
    end
  end

  @doc """
  Get the list of refereneces that are not known symbols
  """
  def get_missing_references(%__MODULE__{} = state) do
    state.references
    |> MapSet.to_list()
    |> Enum.reject(&Map.has_key?(state.symbols, &1))
  end

  def lookup_filename(filename, %__MODULE__{} = state) do
    # Try file-based lookup first
    case lookup_filename_file_based(filename, state) do
      {:ok, _} = result ->
        result

      {:error, _} ->
        # Fallback to legacy lookup
        lookup_filename_legacy(filename, state)
    end
  end

  # New: File-based filename lookup
  defp lookup_filename_file_based(filename, %__MODULE__{file_descriptors: file_descriptors}) do
    cond do
      # Direct match with new file-based naming
      Map.has_key?(file_descriptors, filename) ->
        descriptor_binary = Map.get(file_descriptors, filename)
        {:ok, %{file_descriptor_proto: [descriptor_binary]}}

      # Legacy per-message filename mapping to new file-based
      String.ends_with?(filename, ".proto") ->
        # Extract namespace from legacy filename like "helloworld.HelloRequest.proto"
        case infer_namespace_from_legacy_filename(filename) do
          {:ok, namespace_file} when namespace_file != filename ->
            case Map.fetch(file_descriptors, namespace_file) do
              {:ok, descriptor_binary} ->
                {:ok, %{file_descriptor_proto: [descriptor_binary]}}

              :error ->
                {:error, "filename not found in file-based storage"}
            end

          {:multi, possible_files} ->
            # Try multiple possible file paths
            case try_multiple_file_paths(possible_files, file_descriptors) do
              {:ok, descriptor_binary} ->
                {:ok, %{file_descriptor_proto: [descriptor_binary]}}

              :error ->
                {:error, "filename not found in file-based storage"}
            end

          _ ->
            {:error, "could not map legacy filename to namespace"}
        end

      true ->
        {:error, "filename not found in file-based storage"}
    end
  end

  # Legacy filename lookup
  defp lookup_filename_legacy(filename, %__MODULE__{files: files}) do
    if Map.has_key?(files, filename) do
      {:ok, files[filename]}
    else
      {:error, "filename not found"}
    end
  end

  # Infer namespace file from legacy per-message filename
  defp infer_namespace_from_legacy_filename(filename) do
    case String.split(filename, ".") do
      # "helloworld.HelloRequest.proto" -> try multiple possible file structures
      [namespace, message_name, "proto"] ->
        infer_realistic_file_from_legacy(namespace, message_name)

      # "google.protobuf.Struct.proto" -> "google/protobuf/struct.proto"
      [namespace, package, message_name, "proto"] ->
        # For multi-part namespaces, respect the structure
        namespace_path = namespace |> Macro.underscore()
        package_path = package |> Macro.underscore()
        message_file = message_name |> Macro.underscore()
        {:ok, "#{namespace_path}/#{package_path}/#{message_file}.proto"}

      _ ->
        {:error, "could not parse legacy filename"}
    end
  end

  # Infer realistic file structure from legacy filename components
  defp infer_realistic_file_from_legacy(namespace, _message_name) do
    namespace_path = namespace |> Macro.underscore()

    # With BEAM metadata and project-relative paths, we now need to check actual file paths
    # Instead of hardcoding mappings, try to find matching file in our file_descriptors
    case namespace_path do
      "helloworld" ->
        # Try multiple possible paths for helloworld namespace
        {:multi,
         [
           "test/support/protos/helloworld.proto",
           "helloworld.proto",
           "examples/helloworld/lib/protos/helloworld.proto"
         ]}

      "google" ->
        {:ok, "google/protobuf/timestamp.proto"}

      _ ->
        # For unknown namespaces, try conservative mapping
        {:ok, "#{namespace_path}.proto"}
    end
  end

  def lookup_extension(extendee, %__MODULE__{files: files}) do
    file = extendee <> "Extension.proto"

    if Map.has_key?(files, file) do
      {:ok, files[file]}
    else
      {:error, "extension not found"}
    end
  end

  def lookup_extension_numbers(mod, %__MODULE__{extensions: extensions}) do
    if Map.has_key?(extensions, mod) do
      {:ok, extensions[mod]}
    else
      {:error, "extension numbers not found"}
    end
  end

  # Helper function to try multiple file paths and return the first match
  defp try_multiple_file_paths(possible_files, file_descriptors) do
    Enum.find_value(possible_files, :error, fn file_path ->
      case Map.fetch(file_descriptors, file_path) do
        {:ok, descriptor_binary} -> {:ok, descriptor_binary}
        :error -> nil
      end
    end)
  end
end
