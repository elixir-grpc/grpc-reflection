defmodule NoDescriptor.WellKnownTypes.WellKnownRequest do
  @moduledoc false

  use Protobuf,
    full_name: "well_known_types.WellKnownRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :payload, 1, type: Google.Protobuf.Any
  field :items, 2, repeated: true, type: Google.Protobuf.Any
  field :created_at, 3, type: Google.Protobuf.Timestamp, json_name: "createdAt"
  field :updated_at, 4, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
  field :timeout, 5, type: Google.Protobuf.Duration
  field :retry_delay, 6, type: Google.Protobuf.Duration, json_name: "retryDelay"
  field :metadata, 7, type: Google.Protobuf.Struct
  field :dynamic_value, 8, type: Google.Protobuf.Value, json_name: "dynamicValue"
  field :list_value, 9, type: Google.Protobuf.ListValue, json_name: "listValue"
  field :nullable_string, 10, type: Google.Protobuf.StringValue, json_name: "nullableString"
  field :nullable_int32, 11, type: Google.Protobuf.Int32Value, json_name: "nullableInt32"
  field :nullable_int64, 12, type: Google.Protobuf.Int64Value, json_name: "nullableInt64"
  field :nullable_uint32, 13, type: Google.Protobuf.UInt32Value, json_name: "nullableUint32"
  field :nullable_uint64, 14, type: Google.Protobuf.UInt64Value, json_name: "nullableUint64"
  field :nullable_float, 15, type: Google.Protobuf.FloatValue, json_name: "nullableFloat"
  field :nullable_double, 16, type: Google.Protobuf.DoubleValue, json_name: "nullableDouble"
  field :nullable_bool, 17, type: Google.Protobuf.BoolValue, json_name: "nullableBool"
  field :nullable_bytes, 18, type: Google.Protobuf.BytesValue, json_name: "nullableBytes"
  field :field_mask, 19, type: Google.Protobuf.FieldMask, json_name: "fieldMask"
end

defmodule NoDescriptor.WellKnownTypes.WellKnownResponse do
  @moduledoc false

  use Protobuf,
    full_name: "well_known_types.WellKnownResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :processed_at, 1, type: Google.Protobuf.Timestamp, json_name: "processedAt"
  field :elapsed_time, 2, type: Google.Protobuf.Duration, json_name: "elapsedTime"
  field :result, 3, type: Google.Protobuf.Struct

  field :string_values, 4,
    repeated: true,
    type: Google.Protobuf.StringValue,
    json_name: "stringValues"

  field :int_values, 5, repeated: true, type: Google.Protobuf.Int32Value, json_name: "intValues"
end

defmodule NoDescriptor.WellKnownTypes.CustomPayload do
  @moduledoc false

  use Protobuf,
    full_name: "well_known_types.CustomPayload",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :data, 1, type: :string
  field :version, 2, type: :int32
end

defmodule NoDescriptor.WellKnownTypes.WellKnownTypesService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "well_known_types.WellKnownTypesService",
    protoc_gen_elixir_version: "0.16.0"

  rpc :ProcessWellKnownTypes,
      NoDescriptor.WellKnownTypes.WellKnownRequest,
      NoDescriptor.WellKnownTypes.WellKnownResponse

  rpc :EmptyMethod, Google.Protobuf.Empty, Google.Protobuf.Empty
end

defmodule NoDescriptor.WellKnownTypes.WellKnownTypesService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.WellKnownTypes.WellKnownTypesService.Service
end
