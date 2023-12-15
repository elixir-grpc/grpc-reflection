defmodule TestserviceV2.Enum do
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.12.0", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "Enum",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "A",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "B",
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

  field :A, 0
  field :B, 1
end

defmodule TestserviceV2.TestRequest.GEntry do
  use Protobuf, map: true, protoc_gen_elixir_version: "0.12.0", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GEntry",
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

defmodule TestserviceV2.TestRequest do
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TestRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 1,
          label: :LABEL_REQUIRED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "enum",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".testserviceV2.Enum",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "enum",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "label",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "label",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "g",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".testserviceV2.TestRequest.GEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "g",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "instrument",
          extendee: nil,
          number: 6,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Any",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "instrument",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "GEntry",
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
          start: 10,
          end: 21,
          options: nil,
          __unknown_fields__: []
        }
      ],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "test_oneof",
          options: nil,
          __unknown_fields__: []
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  oneof :test_oneof, 0

  field :name, 1, required: true, type: :string
  field :enum, 2, optional: true, type: TestserviceV2.Enum, enum: true
  field :label, 3, optional: true, type: :string, oneof: 0
  field :value, 4, optional: true, type: :int32, oneof: 0
  field :g, 5, repeated: true, type: TestserviceV2.TestRequest.GEntry, map: true
  field :instrument, 6, repeated: true, type: Google.Protobuf.Any

  extensions [{10, 21}]
end

defmodule TestserviceV2.TestReply do
  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TestReply",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "today",
          extendee: nil,
          number: 2,
          label: :LABEL_REQUIRED,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "today",
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

  field :today, 2, required: true, type: Google.Protobuf.Timestamp
end

defmodule TestserviceV2.TestService.Service do
  use GRPC.Service, name: "testserviceV2.TestService", protoc_gen_elixir_version: "0.12.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "TestService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "CallFunction",
          input_type: ".testserviceV2.TestRequest",
          output_type: ".testserviceV2.TestReply",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
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

  rpc :CallFunction, TestserviceV2.TestRequest, TestserviceV2.TestReply
end

defmodule TestserviceV2.TestService.Stub do
  use GRPC.Stub, service: TestserviceV2.TestService.Service
end

defmodule TestserviceV2.EmptyService.Service do
  use GRPC.Service, name: "testserviceV2.EmptyService", protoc_gen_elixir_version: "0.12.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "EmptyService",
      method: [],
      options: nil,
      __unknown_fields__: []
    }
  end
end

defmodule TestserviceV2.EmptyService.Stub do
  use GRPC.Stub, service: TestserviceV2.EmptyService.Service
end