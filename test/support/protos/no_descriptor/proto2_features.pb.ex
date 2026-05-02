defmodule NoDescriptor.Proto2Features.Status do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "proto2_features.Status",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :UNKNOWN, 0
  field :ACTIVE, 1
  field :INACTIVE, 2
end

defmodule NoDescriptor.Proto2Features.ExtendableMessage.ExtendableEnum do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "proto2_features.ExtendableMessage.ExtendableEnum",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :OPTION_A, 0
  field :OPTION_B, 1
end

defmodule NoDescriptor.Proto2Features.Proto2Request.MetadataMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.Proto2Request.MetadataMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :key, 1, optional: true, type: :string
  field :value, 2, optional: true, type: :int32
end

defmodule NoDescriptor.Proto2Features.Proto2Request do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.Proto2Request",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  oneof :proto2_oneof, 0

  field :required_field, 1, required: true, type: :string, json_name: "requiredField"
  field :required_id, 2, required: true, type: :int32, json_name: "requiredId"
  field :optional_field, 3, optional: true, type: :string, json_name: "optionalField"
  field :optional_id, 4, optional: true, type: :int32, json_name: "optionalId"
  field :name, 5, optional: true, type: :string, default: "unknown"
  field :port, 6, optional: true, type: :int32, default: 8080
  field :enabled, 7, optional: true, type: :bool, default: true

  field :status, 8,
    optional: true,
    type: NoDescriptor.Proto2Features.Status,
    default: :ACTIVE,
    enum: true

  field :oneof_string, 9, optional: true, type: :string, json_name: "oneofString", oneof: 0
  field :oneof_int, 13, optional: true, type: :int32, json_name: "oneofInt", oneof: 0

  field :metadata_map, 14,
    repeated: true,
    type: NoDescriptor.Proto2Features.Proto2Request.MetadataMapEntry,
    json_name: "metadataMap",
    map: true

  field :any_values, 15, repeated: true, type: Google.Protobuf.Any, json_name: "anyValues"

  extensions [{100, 200}]
end

defmodule NoDescriptor.Proto2Features.ExtensionData do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.ExtensionData",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :key, 1, optional: true, type: :string
  field :value, 2, optional: true, type: :string
end

defmodule NoDescriptor.Proto2Features.Proto2Response do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.Proto2Response",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :success, 1, required: true, type: :bool
  field :message, 2, optional: true, type: :string
end

defmodule NoDescriptor.Proto2Features.ExtendableMessage.NestedInExtendable do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.ExtendableMessage.NestedInExtendable",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :data, 1, optional: true, type: :string
end

defmodule NoDescriptor.Proto2Features.ExtendableMessage do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.ExtendableMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  field :id, 1, required: true, type: :string

  extensions [{1000, Protobuf.Extension.max()}]
end

defmodule NoDescriptor.Proto2Features.Proto2Service.Service do
  @moduledoc false

  use GRPC.Service, name: "proto2_features.Proto2Service", protoc_gen_elixir_version: "0.16.0"

  rpc :ProcessProto2,
      NoDescriptor.Proto2Features.Proto2Request,
      NoDescriptor.Proto2Features.Proto2Response
end

defmodule NoDescriptor.Proto2Features.Proto2Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.Proto2Features.Proto2Service.Service
end
