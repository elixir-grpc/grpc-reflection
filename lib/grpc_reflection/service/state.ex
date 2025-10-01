defmodule GrpcReflection.Service.State do
  @moduledoc false

  defstruct services: [], files: %{}, symbols: %{}, extensions: %{}

  @type descriptor_t :: GrpcReflection.Server.descriptor_t()
  @type entry_t :: %{optional(binary()) => descriptor_t()}

  @type t :: %__MODULE__{
          services: list(module()),
          files: entry_t(),
          symbols: entry_t(),
          extensions: %{optional(binary()) => list(integer())}
        }

  @spec new(list(module)) :: t()
  def new(services \\ []), do: %__MODULE__{services: services}

  @spec merge(t(), t()) :: t()
  def merge(%__MODULE__{} = state1, %__MODULE__{} = state2) do
    %__MODULE__{
      services: Enum.uniq(state1.services ++ state2.services),
      files: Map.merge(state1.files, state2.files),
      symbols: Map.merge(state1.symbols, state2.symbols),
      extensions: Map.merge(state1.extensions, state2.extensions)
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
end
