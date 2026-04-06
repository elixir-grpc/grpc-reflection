defmodule PackageB.MessageB do
  @moduledoc false

  use Protobuf,
    full_name: "package_b.MessageB",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MessageB",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "field_b",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "fieldB",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "message_from_a",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".package_a.MessageA",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "messageFromA",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "enum_from_a",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".package_a.EnumA",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "enumFromA",
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

  field :field_b, 1, type: :string, json_name: "fieldB"
  field :message_from_a, 2, type: PackageA.MessageA, json_name: "messageFromA"
  field :enum_from_a, 3, type: PackageA.EnumA, json_name: "enumFromA", enum: true
end

defmodule PackageB.ResponseB do
  @moduledoc false

  use Protobuf,
    full_name: "package_b.ResponseB",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ResponseB",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "results",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".package_a.MessageA",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "results",
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

  field :results, 1, repeated: true, type: PackageA.MessageA
end

defmodule PackageB.ServiceB.Service do
  @moduledoc false

  use GRPC.Service, name: "package_b.ServiceB", protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "ServiceB",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ProcessB",
          input_type: ".package_b.MessageB",
          output_type: ".package_b.ResponseB",
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
          name: "ProcessA",
          input_type: ".package_a.MessageA",
          output_type: ".package_a.MessageA",
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

  rpc :ProcessB, PackageB.MessageB, PackageB.ResponseB

  rpc :ProcessA, PackageA.MessageA, PackageA.MessageA
end

defmodule PackageB.ServiceB.Stub do
  @moduledoc false

  use GRPC.Stub, service: PackageB.ServiceB.Service
end
