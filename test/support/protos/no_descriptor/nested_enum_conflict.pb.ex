defmodule NoDescriptor.NestedEnumConflict.ListFoosRequest.SortOrder do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nestedEnumConflict.ListFoosRequest.SortOrder",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :SORT_ORDER_UNSPECIFIED, 0
  field :SORT_ORDER_NEWEST_FIRST, 1
  field :SORT_ORDER_OLDEST_FIRST, 2
end

defmodule NoDescriptor.NestedEnumConflict.ListBarsRequest.SortOrder do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nestedEnumConflict.ListBarsRequest.SortOrder",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :SORT_ORDER_UNSPECIFIED, 0
  field :SORT_ORDER_NEWEST_FIRST, 1
  field :SORT_ORDER_OLDEST_FIRST, 2
end

defmodule NoDescriptor.NestedEnumConflict.ListFoosRequest do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListFoosRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :sort_order, 1,
    type: NoDescriptor.NestedEnumConflict.ListFoosRequest.SortOrder,
    json_name: "sortOrder",
    enum: true
end

defmodule NoDescriptor.NestedEnumConflict.ListFoosResponse do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListFoosResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule NoDescriptor.NestedEnumConflict.ListBarsRequest do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListBarsRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :sort_order, 1,
    type: NoDescriptor.NestedEnumConflict.ListBarsRequest.SortOrder,
    json_name: "sortOrder",
    enum: true
end

defmodule NoDescriptor.NestedEnumConflict.ListBarsResponse do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListBarsResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule NoDescriptor.NestedEnumConflict.ConflictService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "nestedEnumConflict.ConflictService",
    protoc_gen_elixir_version: "0.16.0"

  rpc :ListFoos,
      NoDescriptor.NestedEnumConflict.ListFoosRequest,
      NoDescriptor.NestedEnumConflict.ListFoosResponse

  rpc :ListBars,
      NoDescriptor.NestedEnumConflict.ListBarsRequest,
      NoDescriptor.NestedEnumConflict.ListBarsResponse
end

defmodule NoDescriptor.NestedEnumConflict.ConflictService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.NestedEnumConflict.ConflictService.Service
end
