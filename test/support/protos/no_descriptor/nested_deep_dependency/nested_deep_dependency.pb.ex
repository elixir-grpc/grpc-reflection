defmodule NoDescriptor.NestedDeepDependency.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Request",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :outer, 1, type: NoDescriptor.NestedDeepDependency.Outer
end

defmodule NoDescriptor.NestedDeepDependency.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Reply",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :message, 1, type: :string
end

defmodule NoDescriptor.NestedDeepDependency.External do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.External",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :value, 1, type: :string
end

defmodule NoDescriptor.NestedDeepDependency.Outer.Middle.Deep do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Outer.Middle.Deep",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :external, 1, type: NoDescriptor.NestedDeepDependency.External
end

defmodule NoDescriptor.NestedDeepDependency.Outer.Middle do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Outer.Middle",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :deep, 1, type: NoDescriptor.NestedDeepDependency.Outer.Middle.Deep
end

defmodule NoDescriptor.NestedDeepDependency.Outer do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Outer",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :middle, 1, type: NoDescriptor.NestedDeepDependency.Outer.Middle
end

defmodule NoDescriptor.NestedDeepDependency.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_deep_dependency.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_deep_dependency.proto"

  rpc :call, NoDescriptor.NestedDeepDependency.Request, NoDescriptor.NestedDeepDependency.Reply
end

defmodule NoDescriptor.NestedDeepDependency.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.NestedDeepDependency.Service.Service
end
