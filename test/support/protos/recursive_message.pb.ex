defmodule RecursiveMessage.Request do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Request",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "reply",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".recursive_message.Reply",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "reply",
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

  field :reply, 1, type: RecursiveMessage.Reply
end

defmodule RecursiveMessage.Reply do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Reply",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "request",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".recursive_message.Request",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "request",
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

  field :request, 1, type: RecursiveMessage.Request
end

defmodule RecursiveMessage.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "recursive_message.Service", protoc_gen_elixir_version: "0.14.1"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Service",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "call",
          input_type: ".recursive_message.Request",
          output_type: ".recursive_message.Reply",
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

  rpc :call, RecursiveMessage.Request, RecursiveMessage.Reply
end

defmodule RecursiveMessage.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: RecursiveMessage.Service.Service
end
