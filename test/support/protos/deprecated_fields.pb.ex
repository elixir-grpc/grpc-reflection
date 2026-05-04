defmodule DeprecatedFields.DeprecatedRequest do
  @moduledoc false

  use Protobuf,
    full_name: "deprecated_fields.DeprecatedRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DeprecatedRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "active_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "activeField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "legacy_field",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          oneof_index: nil,
          json_name: "legacyField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "active_id",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "activeId",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "old_id",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          oneof_index: nil,
          json_name: "oldId",
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

  field :active_field, 1, type: :string, json_name: "activeField"
  field :legacy_field, 2, type: :string, json_name: "legacyField", deprecated: true
  field :active_id, 3, type: :int32, json_name: "activeId"
  field :old_id, 4, type: :int32, json_name: "oldId", deprecated: true
end

defmodule DeprecatedFields.DeprecatedResponse do
  @moduledoc false

  use Protobuf,
    full_name: "deprecated_fields.DeprecatedResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DeprecatedResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "success",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "success",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "result",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "result",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "old_result",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          oneof_index: nil,
          json_name: "oldResult",
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

  field :success, 1, type: :bool
  field :result, 2, type: :string
  field :old_result, 3, type: :string, json_name: "oldResult", deprecated: true
end

defmodule DeprecatedFields.DeprecatedFieldsService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "deprecated_fields.DeprecatedFieldsService",
    protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "DeprecatedFieldsService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "Process",
          input_type: ".deprecated_fields.DeprecatedRequest",
          output_type: ".deprecated_fields.DeprecatedResponse",
          options: nil,
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: []
        }
      ],
      options: nil,
      __unknown_fields__: []
    }
  end

  rpc :Process, DeprecatedFields.DeprecatedRequest, DeprecatedFields.DeprecatedResponse
end

defmodule DeprecatedFields.DeprecatedFieldsService.Stub do
  @moduledoc false

  use GRPC.Stub, service: DeprecatedFields.DeprecatedFieldsService.Service
end
