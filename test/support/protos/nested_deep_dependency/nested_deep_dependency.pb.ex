defmodule NestedDeepDependency.Request do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Request",
    proto_source: "nested_deep_dependency.proto",
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
          type_name: ".nested_deep_dependency.Outer",
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

  field :outer, 1, type: NestedDeepDependency.Outer
end

defmodule NestedDeepDependency.Reply do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Reply",
    proto_source: "nested_deep_dependency.proto",
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

defmodule NestedDeepDependency.External do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.External",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "External",
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

defmodule NestedDeepDependency.Outer.Middle.Deep do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Outer.Middle.Deep",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Deep",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "external",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_deep_dependency.External",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "external",
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

  field :external, 1, type: NestedDeepDependency.External
end

defmodule NestedDeepDependency.Outer.Middle do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Outer.Middle",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Middle",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "deep",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_deep_dependency.Outer.Middle.Deep",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "deep",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "Deep",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "external",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested_deep_dependency.External",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "external",
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

  field :deep, 1, type: NestedDeepDependency.Outer.Middle.Deep
end

defmodule NestedDeepDependency.Outer do
  @moduledoc false

  use Protobuf,
    full_name: "nested_deep_dependency.Outer",
    proto_source: "nested_deep_dependency.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Outer",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "middle",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested_deep_dependency.Outer.Middle",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "middle",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "Middle",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "deep",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested_deep_dependency.Outer.Middle.Deep",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "deep",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [
            %Google.Protobuf.DescriptorProto{
              name: "Deep",
              field: [
                %Google.Protobuf.FieldDescriptorProto{
                  name: "external",
                  extendee: nil,
                  number: 1,
                  label: :LABEL_OPTIONAL,
                  type: :TYPE_MESSAGE,
                  type_name: ".nested_deep_dependency.External",
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "external",
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

  field :middle, 1, type: NestedDeepDependency.Outer.Middle
end

defmodule NestedDeepDependency.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "nested_deep_dependency.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "nested_deep_dependency.proto"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "Service",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "call",
          input_type: ".nested_deep_dependency.Request",
          output_type: ".nested_deep_dependency.Reply",
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

  rpc :call, NestedDeepDependency.Request, NestedDeepDependency.Reply
end

defmodule NestedDeepDependency.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NestedDeepDependency.Service.Service
end
