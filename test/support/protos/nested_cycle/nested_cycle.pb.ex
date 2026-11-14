defmodule NestedCycle.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Request",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Request",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "first",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_cycle.First",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "first",
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

  field :first, 1, type: NestedCycle.First
end

defmodule NestedCycle.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Reply",
    proto_source: "nested_cycle.proto",
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

defmodule NestedCycle.First do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.First",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "First",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "inner",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_cycle.Second.Inner",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "inner",
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

  field :inner, 1, type: NestedCycle.Second.Inner
end

defmodule NestedCycle.Second.Inner do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Second.Inner",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Inner",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "first",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_cycle.First",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "first",
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

  field :first, 1, type: NestedCycle.First
end

defmodule NestedCycle.Second do
  @moduledoc false

  use Protobuf,
    full_name: "nested_cycle.Second",
    proto_source: "nested_cycle.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Second",
      field: [],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "Inner",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "first",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested_cycle.First",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "first",
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
end

defmodule NestedCycle.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_cycle.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_cycle.proto"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Service",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "call",
          input_type: ".nested_cycle.Request",
          output_type: ".nested_cycle.Reply",
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

  rpc :call, NestedCycle.Request, NestedCycle.Reply
end

defmodule NestedCycle.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NestedCycle.Service.Service
end
