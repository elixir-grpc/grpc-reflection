defmodule Proto2Features.Status do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "proto2_features.Status",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "Status",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "UNKNOWN",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ACTIVE",
          number: 1,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "INACTIVE",
          number: 2,
          options: nil,
          __unknown_fields__: []
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :UNKNOWN, 0
  field :ACTIVE, 1
  field :INACTIVE, 2
end

defmodule Proto2Features.ExtendableMessage.ExtendableEnum do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "proto2_features.ExtendableMessage.ExtendableEnum",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "ExtendableEnum",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "OPTION_A",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "OPTION_B",
          number: 1,
          options: nil,
          __unknown_fields__: []
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :OPTION_A, 0
  field :OPTION_B, 1
end

defmodule Proto2Features.Proto2Request.MetadataMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.Proto2Request.MetadataMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MetadataMapEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: []
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :key, 1, optional: true, type: :string
  field :value, 2, optional: true, type: :int32
end

defmodule Proto2Features.Proto2Request do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.Proto2Request",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Proto2Request",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "required_field",
          extendee: nil,
          number: 1,
          label: :LABEL_REQUIRED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "requiredField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "required_id",
          extendee: nil,
          number: 2,
          label: :LABEL_REQUIRED,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "requiredId",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "optional_field",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "optionalField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "optional_id",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "optionalId",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: "unknown",
          options: nil,
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "port",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: "8080",
          options: nil,
          oneof_index: nil,
          json_name: "port",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "enabled",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: "true",
          options: nil,
          oneof_index: nil,
          json_name: "enabled",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".proto2_features.Status",
          default_value: "ACTIVE",
          options: nil,
          oneof_index: nil,
          json_name: "status",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "oneof_string",
          extendee: nil,
          number: 9,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "oneofString",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "oneof_int",
          extendee: nil,
          number: 13,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "oneofInt",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata_map",
          extendee: nil,
          number: 14,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".proto2_features.Proto2Request.MetadataMapEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadataMap",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "any_values",
          extendee: nil,
          number: 15,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Any",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "anyValues",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "packed_ints",
          extendee: nil,
          number: 16,
          label: :LABEL_REPEATED,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: true,
            deprecated: false,
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
          json_name: "packedInts",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "MetadataMapEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_INT32,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: []
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: []
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: []
        }
      ],
      enum_type: [],
      extension_range: [
        %Google.Protobuf.DescriptorProto.ExtensionRange{
          start: 100,
          end: 200,
          options: nil,
          __unknown_fields__: []
        }
      ],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "proto2_oneof",
          options: nil,
          __unknown_fields__: []
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  oneof :proto2_oneof, 0

  field :required_field, 1, required: true, type: :string, json_name: "requiredField"
  field :required_id, 2, required: true, type: :int32, json_name: "requiredId"
  field :optional_field, 3, optional: true, type: :string, json_name: "optionalField"
  field :optional_id, 4, optional: true, type: :int32, json_name: "optionalId"
  field :name, 5, optional: true, type: :string, default: "unknown"
  field :port, 6, optional: true, type: :int32, default: 8080
  field :enabled, 7, optional: true, type: :bool, default: true
  field :status, 8, optional: true, type: Proto2Features.Status, default: :ACTIVE, enum: true
  field :oneof_string, 9, optional: true, type: :string, json_name: "oneofString", oneof: 0
  field :oneof_int, 13, optional: true, type: :int32, json_name: "oneofInt", oneof: 0

  field :metadata_map, 14,
    repeated: true,
    type: Proto2Features.Proto2Request.MetadataMapEntry,
    json_name: "metadataMap",
    map: true

  field :any_values, 15, repeated: true, type: Google.Protobuf.Any, json_name: "anyValues"

  field :packed_ints, 16,
    repeated: true,
    type: :int32,
    json_name: "packedInts",
    packed: true,
    deprecated: false

  extensions [{100, 200}]
end

defmodule Proto2Features.ExtensionData do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.ExtensionData",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ExtensionData",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
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

  field :key, 1, optional: true, type: :string
  field :value, 2, optional: true, type: :string
end

defmodule Proto2Features.Proto2Response do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.Proto2Response",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Proto2Response",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "success",
          extendee: nil,
          number: 1,
          label: :LABEL_REQUIRED,
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
          name: "message",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "message",
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

  field :success, 1, required: true, type: :bool
  field :message, 2, optional: true, type: :string
end

defmodule Proto2Features.ExtendableMessage.NestedInExtendable do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.ExtendableMessage.NestedInExtendable",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NestedInExtendable",
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

  field :data, 1, optional: true, type: :string
end

defmodule Proto2Features.ExtendableMessage do
  @moduledoc false

  use Protobuf,
    full_name: "proto2_features.ExtendableMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ExtendableMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 1,
          label: :LABEL_REQUIRED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "NestedInExtendable",
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
      ],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "ExtendableEnum",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "OPTION_A",
              number: 0,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "OPTION_B",
              number: 1,
              options: nil,
              __unknown_fields__: []
            }
          ],
          options: nil,
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: []
        }
      ],
      extension_range: [
        %Google.Protobuf.DescriptorProto.ExtensionRange{
          start: 1000,
          end: 536_870_912,
          options: nil,
          __unknown_fields__: []
        }
      ],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :id, 1, required: true, type: :string

  extensions [{1000, Protobuf.Extension.max()}]
end

defmodule Proto2Features.Proto2Service.Service do
  @moduledoc false

  use GRPC.Service, name: "proto2_features.Proto2Service", protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Proto2Service",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ProcessProto2",
          input_type: ".proto2_features.Proto2Request",
          output_type: ".proto2_features.Proto2Response",
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

  rpc :ProcessProto2, Proto2Features.Proto2Request, Proto2Features.Proto2Response
end

defmodule Proto2Features.Proto2Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: Proto2Features.Proto2Service.Service
end
