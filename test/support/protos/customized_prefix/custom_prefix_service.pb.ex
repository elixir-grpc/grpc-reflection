defmodule CustomizedPrefix.EchoRequest do
  @moduledoc false

  use Protobuf,
    full_name: "custom_prefix.EchoRequest",
    proto_source: "custom_prefix_service.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "EchoRequest",
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

defmodule CustomizedPrefix.EchoResponse do
  @moduledoc false

  use Protobuf,
    full_name: "custom_prefix.EchoResponse",
    proto_source: "custom_prefix_service.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "EchoResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "reply",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "reply",
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

  field :reply, 1, type: :string
end

defmodule CustomizedPrefix.PrefixService.Service do
  @moduledoc false

  use GRPC.Service, name: "custom_prefix.PrefixService", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "custom_prefix_service.proto"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "PrefixService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "Echo",
          input_type: ".custom_prefix.EchoRequest",
          output_type: ".custom_prefix.EchoResponse",
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

  rpc :Echo, CustomizedPrefix.EchoRequest, CustomizedPrefix.EchoResponse
end

defmodule CustomizedPrefix.PrefixService.Stub do
  @moduledoc false

  use GRPC.Stub, service: CustomizedPrefix.PrefixService.Service
end
