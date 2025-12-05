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
      # each symbol in symbols is in the same package
      # we will combine their files into a single file, and update them to
      # reference this new file

      # Step 1: Collect descriptors to be combined
      symbol_files = Enum.map(symbols, &state_acc.symbols[&1])
      files_to_combine = state_acc.files |> Map.take(symbol_files) |> Map.values()

      # Step 2: Combine the descriptors
      combined_file =
        Enum.reduce(
          files_to_combine,
          %Google.Protobuf.FileDescriptorProto{
            package: package,
            name: package <> ".proto"
          },
          fn descriptor, acc ->
            %{
              acc
              | syntax: descriptor.syntax,
                message_type: Enum.uniq(acc.message_type ++ descriptor.message_type),
                service: Enum.uniq(acc.service ++ descriptor.service),
                enum_type: Enum.uniq(acc.enum_type ++ descriptor.enum_type),
                dependency: Enum.uniq(acc.dependency ++ descriptor.dependency),
                extension: Enum.uniq(acc.extension ++ descriptor.extension)
            }
          end
        )

      # Step 3: remove internal dependency refs
      cleaned_file =
        %{combined_file | dependency: combined_file.dependency -- symbol_files}

      # Step 4: rework state around combined descriptor
      # removing and re-adding symbols pointing to combined file
      # removing combined file descriptors
      # editing existing descriptors for relevant dependency entries
      # add combined file descriptor
      %{
        state_acc
        | symbols:
            state_acc.symbols
            |> Map.drop(symbols)
            |> Map.merge(Map.new(symbols, &{&1, cleaned_file.name})),
          files:
            state_acc.files
            |> Map.drop(symbol_files)
            |> Map.new(fn {filename, descriptor} ->
              if Enum.any?(descriptor.dependency, &Enum.member?(symbol_files, &1)) do
                {
                  filename,
                  %{
                    descriptor
                    | dependency: (descriptor.dependency -- symbol_files) ++ [cleaned_file.name]
                  }
                }
              else
                {filename, descriptor}
              end
            end)
            |> Map.put(cleaned_file.name, cleaned_file)
      }
    end)
  end
end
