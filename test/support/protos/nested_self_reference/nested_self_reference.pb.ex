defmodule NestedSelfReference.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Request",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Request",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "outer",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_self_reference.Outer",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "outer",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
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
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field :outer, 1, type: NestedSelfReference.Outer
end

defmodule NestedSelfReference.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Reply",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Reply",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "message",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "message",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
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
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field :message, 1, type: :string
end

defmodule NestedSelfReference.Outer.Inner do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Outer.Inner",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Inner",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "parent",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_self_reference.Outer",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "parent",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
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
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field :parent, 1, type: NestedSelfReference.Outer
end

defmodule NestedSelfReference.Outer do
  @moduledoc false

  use Protobuf,
    full_name: "nested_self_reference.Outer",
    proto_source: "nested_self_reference.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Outer",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "inner",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_self_reference.Outer.Inner",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "inner",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "Inner",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "parent",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested_self_reference.Outer",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "parent",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
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
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field :inner, 1, type: NestedSelfReference.Outer.Inner
end

defmodule NestedSelfReference.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_self_reference.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_self_reference.proto"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Service",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "call",
          input_type: ".nested_self_reference.Request",
          output_type: ".nested_self_reference.Reply",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  rpc :call, NestedSelfReference.Request, NestedSelfReference.Reply
end

defmodule NestedSelfReference.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NestedSelfReference.Service.Service
end
