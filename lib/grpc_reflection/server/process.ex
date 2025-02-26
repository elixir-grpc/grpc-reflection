defmodule GrpcReflection.Server.Process do
  @moduledoc false
  require Logger

  def reflect(state_mod, {:list_services, _}) do
    state_mod.list_services()
    |> Enum.map(fn name -> %{name: name} end)
    |> then(fn services ->
      {:ok, {:list_services_response, %{service: services}}}
    end)
  end

  def reflect(state_mod, {:file_containing_symbol, symbol}) do
    with {:ok, description} <- state_mod.get_by_symbol(symbol) do
      {:ok, {:file_descriptor_response, description}}
    end
  end

  def reflect(state_mod, {:file_by_filename, filename}) do
    with {:ok, description} <- state_mod.get_by_filename(filename) do
      {:ok, {:file_descriptor_response, description}}
    end
  end

  def reflect(
        state_mod,
        {:file_containing_extension,
         %{containing_type: containing_type, extension_number: _extension_number}}
      ) do
    with {:ok, description} <- state_mod.get_by_extension(containing_type) do
      {:ok, {:file_descriptor_response, description}}
    end
  end

  def reflect(state_mod, {:all_extension_numbers_of_type, mod}) do
    with {:ok, extension_numbers} <- state_mod.get_extension_numbers_by_type(mod) do
      {:ok,
       {:all_extension_numbers_response,
        %{base_type_name: mod, extension_number: extension_numbers}}}
    end
  end

  def reflect(_state_mod, message_request) do
    Logger.warning("received unexpected reflection request: #{inspect(message_request)}")
    {:error, :unimplemented}
  end
end
