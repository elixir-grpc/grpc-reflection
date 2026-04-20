defmodule Proto2Features.PbExtension do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.16.0"

  extend Proto2Features.Proto2Request, :extended_field, 100,
    optional: true,
    type: :string,
    json_name: "extendedField"

  extend Proto2Features.Proto2Request, :extended_timestamp, 101,
    optional: true,
    type: :int64,
    json_name: "extendedTimestamp"

  extend Proto2Features.Proto2Request, :extension_data, 102,
    optional: true,
    type: Proto2Features.ExtensionData,
    json_name: "extensionData"

  extend Proto2Features.Proto2Request, :timestamp_extension, 103,
    optional: true,
    type: Google.Protobuf.Timestamp,
    json_name: "timestampExtension"

  extend Proto2Features.ExtendableMessage, :meta_info, 1000,
    optional: true,
    type: :string,
    json_name: "metaInfo"

  extend Proto2Features.ExtendableMessage, :nested_extension, 1001,
    optional: true,
    type: Proto2Features.ExtendableMessage.NestedInExtendable,
    json_name: "nestedExtension"

  extend Proto2Features.ExtendableMessage, :enum_extension, 1002,
    optional: true,
    type: Proto2Features.ExtendableMessage.ExtendableEnum,
    json_name: "enumExtension",
    enum: true
end
