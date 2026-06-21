defmodule NoDescriptor.DeprecatedFields.DeprecatedRequest do
  @moduledoc false

  use Protobuf,
    full_name: "deprecated_fields.DeprecatedRequest",
    proto_source: "deprecated_fields.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :active_field, 1, type: :string, json_name: "activeField"
  field :legacy_field, 2, type: :string, json_name: "legacyField", deprecated: true
  field :active_id, 3, type: :int32, json_name: "activeId"
  field :old_id, 4, type: :int32, json_name: "oldId", deprecated: true
end

defmodule NoDescriptor.DeprecatedFields.DeprecatedResponse do
  @moduledoc false

  use Protobuf,
    full_name: "deprecated_fields.DeprecatedResponse",
    proto_source: "deprecated_fields.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :success, 1, type: :bool
  field :result, 2, type: :string
  field :old_result, 3, type: :string, json_name: "oldResult", deprecated: true
end

defmodule NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "deprecated_fields.DeprecatedFieldsService",
    protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "deprecated_fields.proto"

  rpc :Process,
      NoDescriptor.DeprecatedFields.DeprecatedRequest,
      NoDescriptor.DeprecatedFields.DeprecatedResponse
end

defmodule NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Service
end
