defmodule NoDescriptor.Nested.ComplexNested.Status do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nested.ComplexNested.Status",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :UNKNOWN, 0
  field :ACTIVE, 1
  field :INACTIVE, 2
end

defmodule NoDescriptor.Nested.ComplexNested.Node.NodeType do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nested.ComplexNested.Node.NodeType",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :LEAF, 0
  field :BRANCH, 1
  field :ROOT, 2
end

defmodule NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :very_deep_field, 1, type: :string, json_name: "veryDeepField"
  field :values, 2, repeated: true, type: :int32
end

defmodule NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :deep_field, 1, type: :string, json_name: "deepField"

  field :very_deep, 2,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage,
    json_name: "veryDeep"
end

defmodule NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage.InnerMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :inner_field, 1, type: :string, json_name: "innerField"
  field :deep, 2, type: NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage
end

defmodule NoDescriptor.Nested.OuterMessage.MiddleMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :middle_field, 1, type: :string, json_name: "middleField"
  field :inner, 2, type: NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage

  field :inner_list, 3,
    repeated: true,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage,
    json_name: "innerList"
end

defmodule NoDescriptor.Nested.OuterMessage.NestedMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.NestedMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: NoDescriptor.Nested.OuterMessage.MiddleMessage
end

defmodule NoDescriptor.Nested.OuterMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  oneof :nested_oneof, 0

  field :outer_field, 1, type: :string, json_name: "outerField"
  field :middle, 2, type: NoDescriptor.Nested.OuterMessage.MiddleMessage

  field :middle_list, 3,
    repeated: true,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage,
    json_name: "middleList"

  field :nested_map, 4,
    repeated: true,
    type: NoDescriptor.Nested.OuterMessage.NestedMapEntry,
    json_name: "nestedMap",
    map: true

  field :option_a, 5,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage,
    json_name: "optionA",
    oneof: 0

  field :option_b, 6,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage,
    json_name: "optionB",
    oneof: 0

  field :simple_option, 7, type: :string, json_name: "simpleOption", oneof: 0
end

defmodule NoDescriptor.Nested.OuterResponse do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :deep_result, 1,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage,
    json_name: "deepResult"

  field :middle_results, 2,
    repeated: true,
    type: NoDescriptor.Nested.OuterMessage.MiddleMessage,
    json_name: "middleResults"
end

defmodule NoDescriptor.Nested.ComplexNested.Node.NamedChildrenEntry do
  @moduledoc false

  use Protobuf,
    full_name: "nested.ComplexNested.Node.NamedChildrenEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: NoDescriptor.Nested.ComplexNested.Node
end

defmodule NoDescriptor.Nested.ComplexNested.Node do
  @moduledoc false

  use Protobuf,
    full_name: "nested.ComplexNested.Node",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :id, 1, type: :string
  field :type, 2, type: NoDescriptor.Nested.ComplexNested.Node.NodeType, enum: true
  field :children, 3, repeated: true, type: NoDescriptor.Nested.ComplexNested.Node
  field :parent, 4, type: NoDescriptor.Nested.ComplexNested.Node

  field :named_children, 5,
    repeated: true,
    type: NoDescriptor.Nested.ComplexNested.Node.NamedChildrenEntry,
    json_name: "namedChildren",
    map: true
end

defmodule NoDescriptor.Nested.ComplexNested do
  @moduledoc false

  use Protobuf,
    full_name: "nested.ComplexNested",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :status, 1, type: NoDescriptor.Nested.ComplexNested.Status, enum: true
  field :root, 2, type: NoDescriptor.Nested.ComplexNested.Node

  field :all_nodes, 3,
    repeated: true,
    type: NoDescriptor.Nested.ComplexNested.Node,
    json_name: "allNodes"
end

defmodule NoDescriptor.Nested.NestedService.Service do
  @moduledoc false

  use GRPC.Service, name: "nested.NestedService", protoc_gen_elixir_version: "0.16.0"

  rpc :ProcessNested, NoDescriptor.Nested.OuterMessage, NoDescriptor.Nested.OuterResponse
end

defmodule NoDescriptor.Nested.NestedService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.Nested.NestedService.Service
end

defmodule NoDescriptor.Nested.AnotherNestedService.Service do
  @moduledoc false

  use GRPC.Service, name: "nested.AnotherNestedService", protoc_gen_elixir_version: "0.16.0"

  rpc :ProcessOuter, NoDescriptor.Nested.OuterMessage, NoDescriptor.Nested.OuterResponse

  rpc :ProcessMiddle,
      NoDescriptor.Nested.OuterMessage.MiddleMessage,
      NoDescriptor.Nested.OuterMessage.MiddleMessage

  rpc :ProcessInner,
      NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage,
      NoDescriptor.Nested.OuterMessage.MiddleMessage.InnerMessage
end

defmodule NoDescriptor.Nested.AnotherNestedService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.Nested.AnotherNestedService.Service
end
