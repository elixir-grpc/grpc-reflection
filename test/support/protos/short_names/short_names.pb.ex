defmodule ShortNames.A do
  @moduledoc false

  use Protobuf,
    full_name: "short_names.A",
    proto_source: "short_names.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "A",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "b",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".short_names.B",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "b",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "lower",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".short_names.lower",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "lower",
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

  field :b, 1, type: ShortNames.B
  field :lower, 2, type: ShortNames.Lower
end

defmodule ShortNames.B do
  @moduledoc false

  use Protobuf,
    full_name: "short_names.B",
    proto_source: "short_names.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "B",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
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

  field :value, 1, type: :string
end

defmodule ShortNames.Lower do
  @moduledoc false

  use Protobuf,
    full_name: "short_names.lower",
    proto_source: "short_names.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "lower",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
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

  field :value, 1, type: :string
end

defmodule ShortNames.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "short_names.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "short_names.proto"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Service",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "call",
          input_type: ".short_names.A",
          output_type: ".short_names.B",
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

  rpc :call, ShortNames.A, ShortNames.B
end

defmodule ShortNames.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: ShortNames.Service.Service
end
