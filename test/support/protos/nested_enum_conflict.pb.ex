defmodule NestedEnumConflict.ListFoosRequest.SortOrder do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nestedEnumConflict.ListFoosRequest.SortOrder",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "SortOrder",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SORT_ORDER_UNSPECIFIED",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SORT_ORDER_NEWEST_FIRST",
          number: 1,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SORT_ORDER_OLDEST_FIRST",
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

  field :SORT_ORDER_UNSPECIFIED, 0
  field :SORT_ORDER_NEWEST_FIRST, 1
  field :SORT_ORDER_OLDEST_FIRST, 2
end

defmodule NestedEnumConflict.ListBarsRequest.SortOrder do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nestedEnumConflict.ListBarsRequest.SortOrder",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "SortOrder",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SORT_ORDER_UNSPECIFIED",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SORT_ORDER_NEWEST_FIRST",
          number: 1,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "SORT_ORDER_OLDEST_FIRST",
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

  field :SORT_ORDER_UNSPECIFIED, 0
  field :SORT_ORDER_NEWEST_FIRST, 1
  field :SORT_ORDER_OLDEST_FIRST, 2
end

defmodule NestedEnumConflict.ListFoosRequest do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListFoosRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListFoosRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "sort_order",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".nestedEnumConflict.ListFoosRequest.SortOrder",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sortOrder",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "SortOrder",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SORT_ORDER_UNSPECIFIED",
              number: 0,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SORT_ORDER_NEWEST_FIRST",
              number: 1,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SORT_ORDER_OLDEST_FIRST",
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
      ],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :sort_order, 1,
    type: NestedEnumConflict.ListFoosRequest.SortOrder,
    json_name: "sortOrder",
    enum: true
end

defmodule NestedEnumConflict.ListFoosResponse do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListFoosResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListFoosResponse",
      field: [],
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
end

defmodule NestedEnumConflict.ListBarsRequest do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListBarsRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListBarsRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "sort_order",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".nestedEnumConflict.ListBarsRequest.SortOrder",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "sortOrder",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "SortOrder",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SORT_ORDER_UNSPECIFIED",
              number: 0,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SORT_ORDER_NEWEST_FIRST",
              number: 1,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "SORT_ORDER_OLDEST_FIRST",
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
      ],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  field :sort_order, 1,
    type: NestedEnumConflict.ListBarsRequest.SortOrder,
    json_name: "sortOrder",
    enum: true
end

defmodule NestedEnumConflict.ListBarsResponse do
  @moduledoc false

  use Protobuf,
    full_name: "nestedEnumConflict.ListBarsResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListBarsResponse",
      field: [],
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
end

defmodule NestedEnumConflict.ConflictService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "nestedEnumConflict.ConflictService",
    protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "ConflictService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ListFoos",
          input_type: ".nestedEnumConflict.ListFoosRequest",
          output_type: ".nestedEnumConflict.ListFoosResponse",
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
          name: "ListBars",
          input_type: ".nestedEnumConflict.ListBarsRequest",
          output_type: ".nestedEnumConflict.ListBarsResponse",
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

  rpc :ListFoos, NestedEnumConflict.ListFoosRequest, NestedEnumConflict.ListFoosResponse

  rpc :ListBars, NestedEnumConflict.ListBarsRequest, NestedEnumConflict.ListBarsResponse
end

defmodule NestedEnumConflict.ConflictService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NestedEnumConflict.ConflictService.Service
end
