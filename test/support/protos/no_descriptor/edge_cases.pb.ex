defmodule NoDescriptor.EdgeCases.DetailedStatus do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "edge_cases.DetailedStatus",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :DETAILED_STATUS_UNSPECIFIED, 0
  field :status_active, 1
  field :STATUS_INACTIVE, 2
  field :Status_Pending, 3
  field :ERROR_STATE, -1
  field :CRITICAL_ERROR, -100
  field :MAX_STATUS, 2_147_483_647
end

defmodule NoDescriptor.EdgeCases.EmptyInputRequest do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.EmptyInputRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule NoDescriptor.EdgeCases.EmptyInputResponse do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.EmptyInputResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :data, 1, type: :string
end

defmodule NoDescriptor.EdgeCases.EmptyOutputRequest do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.EmptyOutputRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :data, 1, type: :string
end

defmodule NoDescriptor.EdgeCases.EmptyOutputResponse do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.EmptyOutputResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule NoDescriptor.EdgeCases.BothEmptyRequest do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.BothEmptyRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule NoDescriptor.EdgeCases.BothEmptyResponse do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.BothEmptyResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3
end

defmodule NoDescriptor.EdgeCases.ComplicatedRequest do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.ComplicatedRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :numbers, 1, type: NoDescriptor.EdgeCases.SparseFieldNumbers
  field :fields, 2, type: NoDescriptor.EdgeCases.ManyFields
  field :status, 3, type: NoDescriptor.EdgeCases.DetailedStatus, enum: true
  field :oneofs, 4, type: NoDescriptor.EdgeCases.MultipleOneofs
  field :nested_maps, 5, type: NoDescriptor.EdgeCases.NestedMaps, json_name: "nestedMaps"
  field :circular, 6, type: NoDescriptor.EdgeCases.CircularA

  field :reserved_fields, 7,
    type: NoDescriptor.EdgeCases.WithReservedFields,
    json_name: "reservedFields"

  field :unicode_test, 8, type: NoDescriptor.EdgeCases.UnicodeTest, json_name: "unicodeTest"
end

defmodule NoDescriptor.EdgeCases.ComplicatedResponse do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.ComplicatedResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :numbers, 1, type: NoDescriptor.EdgeCases.SparseFieldNumbers
  field :fields, 2, type: NoDescriptor.EdgeCases.ManyFields
  field :status, 3, type: NoDescriptor.EdgeCases.DetailedStatus, enum: true
  field :oneofs, 4, type: NoDescriptor.EdgeCases.MultipleOneofs
  field :nested_maps, 5, type: NoDescriptor.EdgeCases.NestedMaps, json_name: "nestedMaps"
  field :circular, 6, type: NoDescriptor.EdgeCases.CircularA

  field :reserved_fields, 7,
    type: NoDescriptor.EdgeCases.WithReservedFields,
    json_name: "reservedFields"

  field :unicode_test, 8, type: NoDescriptor.EdgeCases.UnicodeTest, json_name: "unicodeTest"
end

defmodule NoDescriptor.EdgeCases.SparseFieldNumbers do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.SparseFieldNumbers",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :field_1, 1, type: :string, json_name: "field1"
  field :field_536870911, 536_870_911, type: :string, json_name: "field536870911"
end

defmodule NoDescriptor.EdgeCases.ManyFields do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.ManyFields",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :field_001, 1, type: :string, json_name: "field001"
  field :field_002, 2, type: :string, json_name: "field002"
  field :field_003, 3, type: :string, json_name: "field003"
  field :field_004, 4, type: :string, json_name: "field004"
  field :field_005, 5, type: :string, json_name: "field005"
  field :field_006, 6, type: :string, json_name: "field006"
  field :field_007, 7, type: :string, json_name: "field007"
  field :field_008, 8, type: :string, json_name: "field008"
  field :field_009, 9, type: :string, json_name: "field009"
  field :field_010, 10, type: :string, json_name: "field010"
  field :field_011, 11, type: :string, json_name: "field011"
  field :field_012, 12, type: :string, json_name: "field012"
  field :field_013, 13, type: :string, json_name: "field013"
  field :field_014, 14, type: :string, json_name: "field014"
  field :field_015, 15, type: :string, json_name: "field015"
  field :field_016, 16, type: :string, json_name: "field016"
  field :field_017, 17, type: :string, json_name: "field017"
  field :field_018, 18, type: :string, json_name: "field018"
  field :field_019, 19, type: :string, json_name: "field019"
  field :field_020, 20, type: :string, json_name: "field020"
end

defmodule NoDescriptor.EdgeCases.MultipleOneofs do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.MultipleOneofs",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  oneof :first_choice, 0

  oneof :second_choice, 1

  oneof :third_choice, 2

  field :option_a1, 1, type: :string, json_name: "optionA1", oneof: 0
  field :option_a2, 2, type: :int32, json_name: "optionA2", oneof: 0
  field :option_b1, 3, type: :string, json_name: "optionB1", oneof: 1
  field :option_b2, 4, type: :int32, json_name: "optionB2", oneof: 1
  field :option_c1, 5, type: :string, json_name: "optionC1", oneof: 2
  field :option_c2, 6, type: :int32, json_name: "optionC2", oneof: 2
  field :regular_field, 7, type: :string, json_name: "regularField"
end

defmodule NoDescriptor.EdgeCases.NestedMaps.OuterMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.NestedMaps.OuterMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: NoDescriptor.EdgeCases.InnerMap
end

defmodule NoDescriptor.EdgeCases.NestedMaps.IntKeyMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.NestedMaps.IntKeyMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :int32
  field :value, 2, type: :string
end

defmodule NoDescriptor.EdgeCases.NestedMaps.NumericMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.NestedMaps.NumericMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :int64
  field :value, 2, type: :int64
end

defmodule NoDescriptor.EdgeCases.NestedMaps.BoolKeyMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.NestedMaps.BoolKeyMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :bool
  field :value, 2, type: :string
end

defmodule NoDescriptor.EdgeCases.NestedMaps do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.NestedMaps",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :outer_map, 1,
    repeated: true,
    type: NoDescriptor.EdgeCases.NestedMaps.OuterMapEntry,
    json_name: "outerMap",
    map: true

  field :int_key_map, 2,
    repeated: true,
    type: NoDescriptor.EdgeCases.NestedMaps.IntKeyMapEntry,
    json_name: "intKeyMap",
    map: true

  field :numeric_map, 3,
    repeated: true,
    type: NoDescriptor.EdgeCases.NestedMaps.NumericMapEntry,
    json_name: "numericMap",
    map: true

  field :bool_key_map, 4,
    repeated: true,
    type: NoDescriptor.EdgeCases.NestedMaps.BoolKeyMapEntry,
    json_name: "boolKeyMap",
    map: true
end

defmodule NoDescriptor.EdgeCases.InnerMap.DataEntry do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.InnerMap.DataEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule NoDescriptor.EdgeCases.InnerMap.CountsEntry do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.InnerMap.CountsEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :int32
end

defmodule NoDescriptor.EdgeCases.InnerMap do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.InnerMap",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :data, 1, repeated: true, type: NoDescriptor.EdgeCases.InnerMap.DataEntry, map: true
  field :counts, 2, repeated: true, type: NoDescriptor.EdgeCases.InnerMap.CountsEntry, map: true
end

defmodule NoDescriptor.EdgeCases.CircularA do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.CircularA",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :b_field, 1, type: NoDescriptor.EdgeCases.CircularB, json_name: "bField"
  field :data, 2, type: :string
end

defmodule NoDescriptor.EdgeCases.CircularB do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.CircularB",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :c_field, 1, type: NoDescriptor.EdgeCases.CircularC, json_name: "cField"
  field :data, 2, type: :string
end

defmodule NoDescriptor.EdgeCases.CircularC do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.CircularC",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :a_field, 1, type: NoDescriptor.EdgeCases.CircularA, json_name: "aField"
  field :data, 2, type: :string
end

defmodule NoDescriptor.EdgeCases.WithReservedFields do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.WithReservedFields",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :active_field_1, 1, type: :string, json_name: "activeField1"
  field :active_field_16, 16, type: :string, json_name: "activeField16"
end

defmodule NoDescriptor.EdgeCases.UnicodeTest do
  @moduledoc false

  use Protobuf,
    full_name: "edge_cases.UnicodeTest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :rocket_field, 1, type: :string, json_name: "rocketField"
  field :pi_field, 2, type: :double, json_name: "piField"
  field :greeting, 3, type: :string
end

defmodule NoDescriptor.EdgeCases.EdgeCaseService.Service do
  @moduledoc false

  use GRPC.Service, name: "edge_cases.EdgeCaseService", protoc_gen_elixir_version: "0.16.0"

  rpc :EmptyInput,
      NoDescriptor.EdgeCases.EmptyInputRequest,
      NoDescriptor.EdgeCases.EmptyInputResponse

  rpc :EmptyOutput,
      NoDescriptor.EdgeCases.EmptyOutputRequest,
      NoDescriptor.EdgeCases.EmptyOutputResponse

  rpc :BothEmpty,
      NoDescriptor.EdgeCases.BothEmptyRequest,
      NoDescriptor.EdgeCases.BothEmptyResponse
end

defmodule NoDescriptor.EdgeCases.EdgeCaseService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.EdgeCases.EdgeCaseService.Service
end
