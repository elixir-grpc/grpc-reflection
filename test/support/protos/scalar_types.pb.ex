defmodule ScalarTypes.ScalarRequest do
  @moduledoc false

  use Protobuf,
    full_name: "scalar_types.ScalarRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScalarRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "double_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_DOUBLE,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "doubleField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "float_field",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_FLOAT,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "floatField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "int32_field",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "int32Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "int64_field",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "int64Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "uint32_field",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_UINT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uint32Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "uint64_field",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_UINT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uint64Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sint32_field",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_SINT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sint32Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sint64_field",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_SINT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sint64Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "fixed32_field",
          extendee: nil,
          number: 9,
          label: :LABEL_OPTIONAL,
          type: :TYPE_FIXED32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fixed32Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "fixed64_field",
          extendee: nil,
          number: 10,
          label: :LABEL_OPTIONAL,
          type: :TYPE_FIXED64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fixed64Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sfixed32_field",
          extendee: nil,
          number: 11,
          label: :LABEL_OPTIONAL,
          type: :TYPE_SFIXED32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sfixed32Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sfixed64_field",
          extendee: nil,
          number: 12,
          label: :LABEL_OPTIONAL,
          type: :TYPE_SFIXED64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sfixed64Field",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "bool_field",
          extendee: nil,
          number: 13,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "boolField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "string_field",
          extendee: nil,
          number: 14,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "stringField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "bytes_field",
          extendee: nil,
          number: 15,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "bytesField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "optional_string",
          extendee: nil,
          number: 18,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "optionalString",
          proto3_optional: true,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "optional_int",
          extendee: nil,
          number: 19,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "optionalInt",
          proto3_optional: true,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sparse_field_1",
          extendee: nil,
          number: 100,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sparseField1",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sparse_field_2",
          extendee: nil,
          number: 1000,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sparseField2",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sparse_field_3",
          extendee: nil,
          number: 10000,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sparseField3",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_optional_string",
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_optional_int",
          options: nil,
          __unknown_fields__: []
        }
      ],
      reserved_range: [
        %Google.Protobuf.DescriptorProto.ReservedRange{
          start: 16,
          end: 17,
          __unknown_fields__: []
        },
        %Google.Protobuf.DescriptorProto.ReservedRange{
          start: 17,
          end: 18,
          __unknown_fields__: []
        },
        %Google.Protobuf.DescriptorProto.ReservedRange{start: 20, end: 26, __unknown_fields__: []}
      ],
      reserved_name: ["old_field", "deprecated_field"],
      __unknown_fields__: []
    }
  end

  field :double_field, 1, type: :double, json_name: "doubleField"
  field :float_field, 2, type: :float, json_name: "floatField"
  field :int32_field, 3, type: :int32, json_name: "int32Field"
  field :int64_field, 4, type: :int64, json_name: "int64Field"
  field :uint32_field, 5, type: :uint32, json_name: "uint32Field"
  field :uint64_field, 6, type: :uint64, json_name: "uint64Field"
  field :sint32_field, 7, type: :sint32, json_name: "sint32Field"
  field :sint64_field, 8, type: :sint64, json_name: "sint64Field"
  field :fixed32_field, 9, type: :fixed32, json_name: "fixed32Field"
  field :fixed64_field, 10, type: :fixed64, json_name: "fixed64Field"
  field :sfixed32_field, 11, type: :sfixed32, json_name: "sfixed32Field"
  field :sfixed64_field, 12, type: :sfixed64, json_name: "sfixed64Field"
  field :bool_field, 13, type: :bool, json_name: "boolField"
  field :string_field, 14, type: :string, json_name: "stringField"
  field :bytes_field, 15, type: :bytes, json_name: "bytesField"
  field :optional_string, 18, proto3_optional: true, type: :string, json_name: "optionalString"
  field :optional_int, 19, proto3_optional: true, type: :int32, json_name: "optionalInt"
  field :sparse_field_1, 100, type: :string, json_name: "sparseField1"
  field :sparse_field_2, 1000, type: :string, json_name: "sparseField2"
  field :sparse_field_3, 10000, type: :string, json_name: "sparseField3"
end

defmodule ScalarTypes.ScalarReply do
  @moduledoc false

  use Protobuf,
    full_name: "scalar_types.ScalarReply",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScalarReply",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "double_list",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_DOUBLE,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "doubleList",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "float_list",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_FLOAT,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "floatList",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "int32_list",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "int32List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "int64_list",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_INT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "int64List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "uint32_list",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_UINT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uint32List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "uint64_list",
          extendee: nil,
          number: 6,
          label: :LABEL_REPEATED,
          type: :TYPE_UINT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uint64List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sint32_list",
          extendee: nil,
          number: 7,
          label: :LABEL_REPEATED,
          type: :TYPE_SINT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sint32List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sint64_list",
          extendee: nil,
          number: 8,
          label: :LABEL_REPEATED,
          type: :TYPE_SINT64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sint64List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "fixed32_list",
          extendee: nil,
          number: 9,
          label: :LABEL_REPEATED,
          type: :TYPE_FIXED32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fixed32List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "fixed64_list",
          extendee: nil,
          number: 10,
          label: :LABEL_REPEATED,
          type: :TYPE_FIXED64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fixed64List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sfixed32_list",
          extendee: nil,
          number: 11,
          label: :LABEL_REPEATED,
          type: :TYPE_SFIXED32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sfixed32List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "sfixed64_list",
          extendee: nil,
          number: 12,
          label: :LABEL_REPEATED,
          type: :TYPE_SFIXED64,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sfixed64List",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "bool_list",
          extendee: nil,
          number: 13,
          label: :LABEL_REPEATED,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "boolList",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "string_list",
          extendee: nil,
          number: 14,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "stringList",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "bytes_list",
          extendee: nil,
          number: 15,
          label: :LABEL_REPEATED,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "bytesList",
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

  field :double_list, 1, repeated: true, type: :double, json_name: "doubleList"
  field :float_list, 2, repeated: true, type: :float, json_name: "floatList"
  field :int32_list, 3, repeated: true, type: :int32, json_name: "int32List"
  field :int64_list, 4, repeated: true, type: :int64, json_name: "int64List"
  field :uint32_list, 5, repeated: true, type: :uint32, json_name: "uint32List"
  field :uint64_list, 6, repeated: true, type: :uint64, json_name: "uint64List"
  field :sint32_list, 7, repeated: true, type: :sint32, json_name: "sint32List"
  field :sint64_list, 8, repeated: true, type: :sint64, json_name: "sint64List"
  field :fixed32_list, 9, repeated: true, type: :fixed32, json_name: "fixed32List"
  field :fixed64_list, 10, repeated: true, type: :fixed64, json_name: "fixed64List"
  field :sfixed32_list, 11, repeated: true, type: :sfixed32, json_name: "sfixed32List"
  field :sfixed64_list, 12, repeated: true, type: :sfixed64, json_name: "sfixed64List"
  field :bool_list, 13, repeated: true, type: :bool, json_name: "boolList"
  field :string_list, 14, repeated: true, type: :string, json_name: "stringList"
  field :bytes_list, 15, repeated: true, type: :bytes, json_name: "bytesList"
end

defmodule ScalarTypes.ScalarService.Service do
  @moduledoc false

  use GRPC.Service, name: "scalar_types.ScalarService", protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "ScalarService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ProcessScalars",
          input_type: ".scalar_types.ScalarRequest",
          output_type: ".scalar_types.ScalarReply",
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

  rpc :ProcessScalars, ScalarTypes.ScalarRequest, ScalarTypes.ScalarReply
end

defmodule ScalarTypes.ScalarService.Stub do
  @moduledoc false

  use GRPC.Stub, service: ScalarTypes.ScalarService.Service
end
