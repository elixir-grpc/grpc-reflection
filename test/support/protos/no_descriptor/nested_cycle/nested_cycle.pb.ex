defmodule NoDescriptor.NestedCycle.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Request",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :first, 1, type: NoDescriptor.NestedCycle.First
end

defmodule NoDescriptor.NestedCycle.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Reply",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :message, 1, type: :string
end

defmodule NoDescriptor.NestedCycle.First do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.First",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :inner, 1, type: NoDescriptor.NestedCycle.Second.Inner
end

defmodule NoDescriptor.NestedCycle.Second.Inner do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Second.Inner",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :first, 1, type: NoDescriptor.NestedCycle.First
end

defmodule NoDescriptor.NestedCycle.Second do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Second",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3
end

defmodule NoDescriptor.NestedCycle.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_cycle.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_cycle.proto"

  rpc :call, NoDescriptor.NestedCycle.Request, NoDescriptor.NestedCycle.Reply
end

defmodule NoDescriptor.NestedCycle.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.NestedCycle.Service.Service
end
