defmodule NoDescriptor.EmptyService.EmptyService.Service do
  @moduledoc false

  use GRPC.Service, name: "empty_service.EmptyService", protoc_gen_elixir_version: "0.16.0"
end

defmodule NoDescriptor.EmptyService.EmptyService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.EmptyService.EmptyService.Service
end
