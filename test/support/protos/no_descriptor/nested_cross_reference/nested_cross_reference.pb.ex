defmodule NoDescriptor.NestedCrossReference.Holder.Kind do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nested_cross_reference.Holder.Kind",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :KIND_UNSPECIFIED, 0
  field :KIND_ONE, 1
end

defmodule NoDescriptor.NestedCrossReference.Holder.UnusedKind do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nested_cross_reference.Holder.UnusedKind",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :UNUSED_KIND_UNSPECIFIED, 0
end

defmodule NoDescriptor.NestedCrossReference.Request.ItemsEntry do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Request.ItemsEntry",
    map: true,
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: NoDescriptor.NestedCrossReference.Holder.Item
end

defmodule NoDescriptor.NestedCrossReference.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Request",
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :item, 1, type: NoDescriptor.NestedCrossReference.Holder.Item
  field :kind, 2, type: NoDescriptor.NestedCrossReference.Holder.Kind, enum: true

  field :items, 3,
    repeated: true,
    type: NoDescriptor.NestedCrossReference.Request.ItemsEntry,
    map: true
end

defmodule NoDescriptor.NestedCrossReference.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Reply",
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :message, 1, type: :string
end

defmodule NoDescriptor.NestedCrossReference.Holder.Item do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Holder.Item",
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :name, 1, type: :string
end

defmodule NoDescriptor.NestedCrossReference.Holder.Unused do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Holder.Unused",
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :note, 1, type: :string
  field :extra, 2, type: NoDescriptor.NestedCrossReference.Extra
end

defmodule NoDescriptor.NestedCrossReference.Holder do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Holder",
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3
end

defmodule NoDescriptor.NestedCrossReference.Extra do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cross_reference.Extra",
    proto_source: "nested_cross_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :value, 1, type: :string
end

defmodule NoDescriptor.NestedCrossReference.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_cross_reference.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_cross_reference.proto"

  rpc :call, NoDescriptor.NestedCrossReference.Request, NoDescriptor.NestedCrossReference.Reply

  rpc :callItem,
      NoDescriptor.NestedCrossReference.Holder.Item,
      NoDescriptor.NestedCrossReference.Reply
end

defmodule NoDescriptor.NestedCrossReference.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.NestedCrossReference.Service.Service
end
