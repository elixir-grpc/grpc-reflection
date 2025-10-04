defmodule GrpcReflection.Service.Builder.Acc do
  @moduledoc false

  defstruct services: [],
            symbol_info: %{},
            aliases: %{},
            visited: MapSet.new(),
            extension_files: %{},
            extensions: %{}
end
