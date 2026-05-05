defmodule NoDescriptor.ScalarTypes.ScalarRequest do
  @moduledoc false

  use Protobuf,
    full_name: "scalar_types.ScalarRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

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

defmodule NoDescriptor.ScalarTypes.ScalarReply do
  @moduledoc false

  use Protobuf,
    full_name: "scalar_types.ScalarReply",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

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

defmodule NoDescriptor.ScalarTypes.ScalarService.Service do
  @moduledoc false

  use GRPC.Service, name: "scalar_types.ScalarService", protoc_gen_elixir_version: "0.16.0"

  rpc :ProcessScalars,
      NoDescriptor.ScalarTypes.ScalarRequest,
      NoDescriptor.ScalarTypes.ScalarReply
end

defmodule NoDescriptor.ScalarTypes.ScalarService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.ScalarTypes.ScalarService.Service
end
