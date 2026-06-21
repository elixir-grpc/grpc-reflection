defmodule NoDescriptor.RecursiveMessage.Request do
  @moduledoc false

  use Protobuf,
    full_name: "recursive_message.Request",
    proto_source: "recursive_message.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :reply, 1, type: NoDescriptor.RecursiveMessage.Reply
end

defmodule NoDescriptor.RecursiveMessage.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "recursive_message.Reply",
    proto_source: "recursive_message.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :request, 1, type: NoDescriptor.RecursiveMessage.Request
end

defmodule NoDescriptor.RecursiveMessage.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "recursive_message.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "recursive_message.proto"

  rpc :call, NoDescriptor.RecursiveMessage.Request, NoDescriptor.RecursiveMessage.Reply
end

defmodule NoDescriptor.RecursiveMessage.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.RecursiveMessage.Service.Service
end
