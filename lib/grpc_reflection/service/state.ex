defmodule GrpcReflection.Service.State do
  @moduledoc false

  defstruct services: [], files: %{}, symbols: %{}, extensions: %{}

  @type descriptor_t :: Google.Protobuf.FileDescriptorProto.t()
  @type symbol_t :: %{optional(binary()) => binary()}
  @type entry_t :: %{optional(binary()) => descriptor_t()}

  @type t :: %__MODULE__{
          services: list(module()),
          files: entry_t(),
          symbols: symbol_t(),
          extensions: %{optional(binary()) => list(integer())}
        }

  @spec new(list(module)) :: t()
  def new(services \\ []), do: %__MODULE__{services: services}

  @spec merge(t(), t()) :: t()
  def merge(%__MODULE__{} = state1, %__MODULE__{} = state2) do
    %__MODULE__{
      services: Enum.uniq(state1.services ++ state2.services),
      files: merge_map!("Files", state1.files, state2.files),
      symbols: merge_map!("Symbols", state1.symbols, state2.symbols),
      extensions: merge_map!("Extensions", state1.extensions, state2.extensions)
    }
  end

  # merge two maps, but raise if we have duplicate keys with different values
  defp merge_map!(type, current_map, incoming_map) do
    Map.merge(current_map, incoming_map, fn
      _key, value, value ->
        value

      key, _left, _right ->
        raise "#{type} Conflict detected: key #{key} present with multiple values"
    end)
  end

  # add an item to a map, but raise if the key exists with a different value
  defp put_map!(type, current_map, key, value) do
    case current_map[key] do
      nil -> Map.put(current_map, key, value)
      ^value -> current_map
      _ -> raise "#{type} Conflict detected: key #{key} present with multiple values"
    end
  end

  @spec add_file(t(), descriptor_t()) :: t()
  def add_file(%__MODULE__{} = state, descriptor) do
    %{state | files: put_map!("Files", state.files, descriptor.name, descriptor)}
  end

  @spec add_symbol(t(), String.t(), String.t()) :: t()
  def add_symbol(%__MODULE__{files: files} = state, symbol, filename) do
    if files[filename] == nil do
      raise "Symbol #{symbol} added for file that doesn't exist: #{filename}"
    end

    %{state | symbols: put_map!("Symbols", state.symbols, symbol, filename)}
  end

  def add_extensions(%__MODULE__{} = state, extensions) do
    %{state | extensions: Map.merge(extensions, state.extensions)}
  end

  def lookup_services(%__MODULE__{services: services}) do
    Enum.map(services, fn service_mod -> service_mod.__meta__(:name) end)
  end

  def lookup_symbol("." <> symbol, state), do: lookup_symbol(symbol, state)

  def lookup_symbol(symbol, %__MODULE__{symbols: symbols}) do
    if Map.has_key?(symbols, symbol) do
      {:ok, symbols[symbol]}
    else
      {:error, "symbol not found"}
    end
  end

  @doc """
  Check if the given symbol is already tracked in the state
  """
  def has_symbol?(state, "." <> symbol) do
    Map.has_key?(state.symbols, symbol)
  end

  def has_symbol?(state, symbol) do
    Map.has_key?(state.symbols, symbol)
  end

  def lookup_filename(filename, %__MODULE__{files: files}) do
    if Map.has_key?(files, filename) do
      {:ok, files[filename]}
    else
      {:error, "filename not found"}
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

  def group_symbols_by_namespace(%__MODULE__{} = state) do
    state.symbols
    |> Map.keys()
    |> Enum.group_by(&GrpcReflection.Service.Builder.Util.get_package(&1))
    |> Enum.reduce(state, fn {package, symbols}, state_acc ->
      symbol_files = Enum.map(symbols, &state_acc.symbols[&1])
      files_to_combine = state_acc.files |> Map.take(symbol_files) |> Map.values()
      combined_file = combine_file_descriptors(package, files_to_combine)
      update_state_with_combined_file(state_acc, combined_file, symbol_files)
    end)
  end

  defp update_state_with_combined_file(state, combined_file, combined_filenames) do
    # Update files: remove old entries, add new one with updated dependencies
    new_files =
      state.files
      |> Map.drop(combined_filenames)
      |> Map.new(fn {filename, descriptor} ->
        if Enum.any?(descriptor.dependency, &Enum.member?(combined_filenames, &1)) do
          {
            filename,
            %{
              descriptor
              | dependency: (descriptor.dependency -- combined_filenames) ++ [combined_file.name]
            }
          }
        else
          {filename, descriptor}
        end
      end)
      |> Map.put(combined_file.name, combined_file)

    # Update symbols: map old symbols to point to the new combined file
    new_symbols =
      Map.new(state.symbols, fn {symbol, filename} ->
        if filename in combined_filenames do
          {symbol, combined_file.name}
        else
          {symbol, filename}
        end
      end)

    %{state | files: new_files, symbols: new_symbols}
  end

  defp combine_file_descriptors(name, file_descriptors) do
    acc = %Google.Protobuf.FileDescriptorProto{
      package: name,
      name: name <> ".proto"
    }

    combined_names = Enum.map(file_descriptors, & &1.name)

    Enum.reduce(file_descriptors, acc, fn descriptor, acc ->
      %{
        acc
        | syntax: acc.syntax || descriptor.syntax,
          package: acc.package || descriptor.package,
          name: acc.name || descriptor.name,
          message_type: Enum.uniq(acc.message_type ++ descriptor.message_type),
          service: Enum.uniq(acc.service ++ descriptor.service),
          enum_type: Enum.uniq(acc.enum_type ++ descriptor.enum_type),
          dependency: Enum.uniq(acc.dependency ++ (descriptor.dependency -- combined_names)),
          extension: Enum.uniq(acc.extension ++ descriptor.extension)
      }
    end)
  end
end
