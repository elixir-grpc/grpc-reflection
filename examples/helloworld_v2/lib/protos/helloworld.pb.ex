defmodule HLW.HelloRequest do
  @moduledoc """
  The request message containing the user's name.
  """

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "HelloRequest",
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
          name: "meta",
          extendee: nil,
          number: 2,
          label: :LABEL_REQUIRED,
          type: :TYPE_MESSAGE,
          type_name: ".helloworld.MessageMetadata",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "meta",
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

  field :name, 1, required: true, type: :string
  field :meta, 2, required: true, type: HLW.MessageMetadata
end

defmodule HLW.MessageMetadata do
  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MessageMetadata",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "user",
          extendee: nil,
          number: 1,
          label: :LABEL_REQUIRED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "user",
          proto3_optional: nil,
          __unknown_fields__: []
        },
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

  field :user, 1, required: true, type: :string
  field :today, 2, required: true, type: Google.Protobuf.Timestamp
end

defmodule HLW.HelloReply do
  @moduledoc """
  The response message containing the greetings
  """

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto2

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "HelloReply",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "message",
          extendee: nil,
          number: 1,
          label: :LABEL_REQUIRED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "message",
          proto3_optional: nil,
          __unknown_fields__: []
        },
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

  field :message, 1, required: true, type: :string
  field :today, 2, required: true, type: Google.Protobuf.Timestamp
end

defmodule HLW.Greeter.Service do
  @moduledoc """
  The greeting service definition.
  """

  use GRPC.Service, name: "helloworld.Greeter", protoc_gen_elixir_version: "0.14.1"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Greeter",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "SayHello",
          input_type: ".helloworld.HelloRequest",
          output_type: ".helloworld.HelloReply",
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

  rpc :SayHello, HLW.HelloRequest, HLW.HelloReply
end

defmodule HLW.Greeter.Stub do
  use GRPC.Stub, service: HLW.Greeter.Service
end
