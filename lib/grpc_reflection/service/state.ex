defmodule GrpcReflection.Service.State do
  @moduledoc false

  defstruct services: [], files: %{}, symbols: %{}, extensions: %{}

  @type descriptor_t :: GrpcReflection.Server.descriptor_t()
  @type t :: %__MODULE__{
          services: list(module()),
          files: %{optional(binary()) => descriptor_t()},
          symbols: %{optional(binary()) => descriptor_t()},
          extensions: %{optional(binary()) => list(integer())}
        }

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
