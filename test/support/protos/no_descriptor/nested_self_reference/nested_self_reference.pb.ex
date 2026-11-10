defmodule NoDescriptor.NestedSelfReference.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Request",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :outer, 1, type: NoDescriptor.NestedSelfReference.Outer
end

defmodule NoDescriptor.NestedSelfReference.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Reply",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :message, 1, type: :string
end

defmodule NoDescriptor.NestedSelfReference.Outer.Inner do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Outer.Inner",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :parent, 1, type: NoDescriptor.NestedSelfReference.Outer
end

defmodule NoDescriptor.NestedSelfReference.Outer do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Outer",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :inner, 1, type: NoDescriptor.NestedSelfReference.Outer.Inner
end

defmodule NoDescriptor.NestedSelfReference.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_self_reference.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_self_reference.proto"

  rpc :call, NoDescriptor.NestedSelfReference.Request, NoDescriptor.NestedSelfReference.Reply
end

defmodule NoDescriptor.NestedSelfReference.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.NestedSelfReference.Service.Service
end
