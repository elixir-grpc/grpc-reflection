defmodule NoDescriptor.EmptyService.EmptyService.Service do
  @moduledoc false

  use GRPC.Service, name: "empty_service.EmptyService", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "empty_service.proto"
end

defmodule NoDescriptor.EmptyService.EmptyService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.EmptyService.EmptyService.Service
end
