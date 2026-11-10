defmodule NoDescriptor.SelfReference.Request do
  @moduledoc false

  use Protobuf,
    full_name: "self_reference.Request",
    proto_source: "self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :name, 1, type: :string
  field :child, 2, type: NoDescriptor.SelfReference.Request
  field :children, 3, repeated: true, type: NoDescriptor.SelfReference.Request
end

defmodule NoDescriptor.SelfReference.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "self_reference.Reply",
    proto_source: "self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :message, 1, type: :string
end

defmodule NoDescriptor.SelfReference.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "self_reference.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "self_reference.proto"

  rpc :call, NoDescriptor.SelfReference.Request, NoDescriptor.SelfReference.Reply
end

defmodule NoDescriptor.SelfReference.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.SelfReference.Service.Service
end
