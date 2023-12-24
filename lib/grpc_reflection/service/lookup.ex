defmodule GrpcReflection.Service.Lookup do
  @moduledoc false

  alias GrpcReflection.Service.State

  def lookup_services(%State{services: services}) do
    Enum.map(services, fn service_mod -> service_mod.__meta__(:name) end)
  end

  def lookup_symbol("." <> symbol, state), do: lookup_symbol(symbol, state)

  def lookup_symbol(symbol, %State{symbols: symbols}) do
    if Map.has_key?(symbols, symbol) do
      {:ok, symbols[symbol]}
    else
      {:error, "symbol not found"}
    end
  end

  def lookup_filename(filename, %State{files: files}) do
    if Map.has_key?(files, filename) do
      {:ok, files[filename]}
    else
      {:error, "filename not found"}
    end
  end

  def lookup_extension(extendee, %State{files: files}) do
    file = extendee <> "Extension.proto"

    if Map.has_key?(files, file) do
      {:ok, files[file]}
    else
      {:error, "extension not found"}
    end
  end

  def lookup_extension_numbers(mod, %State{extensions: extensions}) do
    if Map.has_key?(extensions, mod) do
      {:ok, extensions[mod]}
    else
      {:error, "extension numbers not found"}
    end
  end
end
