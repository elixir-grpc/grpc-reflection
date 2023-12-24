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
end
