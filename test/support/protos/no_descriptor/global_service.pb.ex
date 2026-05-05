defmodule NoDescriptor.GlobalRequest do
  @moduledoc false

  use Protobuf, full_name: "GlobalRequest", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :data, 1, type: :string
end

defmodule NoDescriptor.GlobalResponse do
  @moduledoc false

  use Protobuf, full_name: "GlobalResponse", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :result, 1, type: :string
end

defmodule NoDescriptor.GlobalService.Service do
  @moduledoc false

  use GRPC.Service, name: "GlobalService", protoc_gen_elixir_version: "0.16.0"

  rpc :GlobalMethod, NoDescriptor.GlobalRequest, NoDescriptor.GlobalResponse
end

defmodule NoDescriptor.GlobalService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.GlobalService.Service
end
