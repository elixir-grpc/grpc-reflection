defmodule NoDescriptor.GlobalRequest do
  @moduledoc false

  use Protobuf,
    full_name: "GlobalRequest",
    proto_source: "global_service.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :data, 1, type: :string
end

defmodule NoDescriptor.GlobalResponse do
  @moduledoc false

  use Protobuf,
    full_name: "GlobalResponse",
    proto_source: "global_service.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :result, 1, type: :string
end

defmodule NoDescriptor.GlobalService.Service do
  @moduledoc false

  use GRPC.Service, name: "GlobalService", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "global_service.proto"

  rpc :GlobalMethod, NoDescriptor.GlobalRequest, NoDescriptor.GlobalResponse
end

defmodule NoDescriptor.GlobalService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.GlobalService.Service
end
