defmodule WellKnownTypes.WellKnownRequest do
  @moduledoc false

  use Protobuf,
    full_name: "well_known_types.WellKnownRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "WellKnownRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "payload",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Any",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "payload",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "items",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Any",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "items",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "created_at",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "createdAt",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "updated_at",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "updatedAt",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "timeout",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Duration",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "timeout",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "retry_delay",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Duration",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "retryDelay",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "dynamic_value",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Value",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "dynamicValue",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "list_value",
          extendee: nil,
          number: 9,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.ListValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "listValue",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_string",
          extendee: nil,
          number: 10,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.StringValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableString",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_int32",
          extendee: nil,
          number: 11,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Int32Value",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableInt32",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_int64",
          extendee: nil,
          number: 12,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Int64Value",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableInt64",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_uint32",
          extendee: nil,
          number: 13,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.UInt32Value",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableUint32",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_uint64",
          extendee: nil,
          number: 14,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.UInt64Value",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableUint64",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_float",
          extendee: nil,
          number: 15,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.FloatValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableFloat",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_double",
          extendee: nil,
          number: 16,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.DoubleValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableDouble",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_bool",
          extendee: nil,
          number: 17,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.BoolValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableBool",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nullable_bytes",
          extendee: nil,
          number: 18,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.BytesValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nullableBytes",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "field_mask",
          extendee: nil,
          number: 19,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.FieldMask",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fieldMask",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

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

defmodule WellKnownTypes.WellKnownResponse do
  @moduledoc false

  use Protobuf,
    full_name: "well_known_types.WellKnownResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "WellKnownResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "processed_at",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "processedAt",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "elapsed_time",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Duration",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "elapsedTime",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "result",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "result",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "string_values",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.StringValue",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "stringValues",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "int_values",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Int32Value",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "intValues",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :processed_at, 1, type: Google.Protobuf.Timestamp, json_name: "processedAt"
  field :elapsed_time, 2, type: Google.Protobuf.Duration, json_name: "elapsedTime"
  field :result, 3, type: Google.Protobuf.Struct

  field :string_values, 4,
    repeated: true,
    type: Google.Protobuf.StringValue,
    json_name: "stringValues"

  field :int_values, 5, repeated: true, type: Google.Protobuf.Int32Value, json_name: "intValues"
end

defmodule WellKnownTypes.CustomPayload do
  @moduledoc false

  use Protobuf,
    full_name: "well_known_types.CustomPayload",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CustomPayload",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "data",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "data",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "version",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "version",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :data, 1, type: :string
  field :version, 2, type: :int32
end

defmodule WellKnownTypes.WellKnownTypesService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "well_known_types.WellKnownTypesService",
    protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "WellKnownTypesService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ProcessWellKnownTypes",
          input_type: ".well_known_types.WellKnownRequest",
          output_type: ".well_known_types.WellKnownResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: []
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "EmptyMethod",
          input_type: ".google.protobuf.Empty",
          output_type: ".google.protobuf.Empty",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: []
        }
      ],
      options: nil,
      __unknown_fields__: []
    }
  end

  rpc :ProcessWellKnownTypes, WellKnownTypes.WellKnownRequest, WellKnownTypes.WellKnownResponse

  rpc :EmptyMethod, Google.Protobuf.Empty, Google.Protobuf.Empty
end

defmodule WellKnownTypes.WellKnownTypesService.Stub do
  @moduledoc false

  use GRPC.Stub, service: WellKnownTypes.WellKnownTypesService.Service
end
