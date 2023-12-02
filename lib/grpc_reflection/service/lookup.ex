defmodule GrpcReflection.Service.Lookup do
  @moduledoc false

  alias GrpcReflection.Service.Agent

  def lookup_services(%Agent{services: services}) do
    Enum.map(services, fn service_mod -> service_mod.__meta__(:name) end)
  end

  def lookup_symbol("." <> symbol, state), do: lookup_symbol(symbol, state)

  def lookup_symbol(symbol, %Agent{symbols: symbols}) do
    if Map.has_key?(symbols, symbol) do
      {:ok, symbols[symbol]}
    else
      {:error, "symbol not found"}
    end
  end

  def lookup_filename(filename, %Agent{files: files}) do
    if Map.has_key?(files, filename) do
      {:ok, files[filename]}
    else
      {:error, "filename not found"}
    end
  end
end
