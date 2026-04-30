defmodule Nested.ComplexNested.Status do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nested.ComplexNested.Status",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "Status",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "UNKNOWN",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ACTIVE",
          number: 1,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "INACTIVE",
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

  field :UNKNOWN, 0
  field :ACTIVE, 1
  field :INACTIVE, 2
end

defmodule Nested.ComplexNested.Node.NodeType do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "nested.ComplexNested.Node.NodeType",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "NodeType",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "LEAF",
          number: 0,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "BRANCH",
          number: 1,
          options: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ROOT",
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

  field :LEAF, 0
  field :BRANCH, 1
  field :ROOT, 2
end

defmodule Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "VeryDeepMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "very_deep_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "veryDeepField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "values",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "values",
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

  field :very_deep_field, 1, type: :string, json_name: "veryDeepField"
  field :values, 2, repeated: true, type: :int32
end

defmodule Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DeepMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "deep_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "deepField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "very_deep",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name:
            ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "veryDeep",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "VeryDeepMessage",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "very_deep_field",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "veryDeepField",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "values",
              extendee: nil,
              number: 2,
              label: :LABEL_REPEATED,
              type: :TYPE_INT32,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "values",
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
      ],
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

  field :deep_field, 1, type: :string, json_name: "deepField"

  field :very_deep, 2,
    type: Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage,
    json_name: "veryDeep"
end

defmodule Nested.OuterMessage.MiddleMessage.InnerMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage.InnerMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "InnerMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "inner_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "innerField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "deep",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "deep",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "DeepMessage",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "deep_field",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "deepField",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "very_deep",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name:
                ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "veryDeep",
              proto3_optional: nil,
              __unknown_fields__: []
            }
          ],
          nested_type: [
            %Google.Protobuf.DescriptorProto{
              name: "VeryDeepMessage",
              field: [
                %Google.Protobuf.FieldDescriptorProto{
                  name: "very_deep_field",
                  extendee: nil,
                  number: 1,
                  label: :LABEL_OPTIONAL,
                  type: :TYPE_STRING,
                  type_name: nil,
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "veryDeepField",
                  proto3_optional: nil,
                  __unknown_fields__: []
                },
                %Google.Protobuf.FieldDescriptorProto{
                  name: "values",
                  extendee: nil,
                  number: 2,
                  label: :LABEL_REPEATED,
                  type: :TYPE_INT32,
                  type_name: nil,
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "values",
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
          ],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: nil,
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: []
        }
      ],
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

  field :inner_field, 1, type: :string, json_name: "innerField"
  field :deep, 2, type: Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage
end

defmodule Nested.OuterMessage.MiddleMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.MiddleMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MiddleMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "middle_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "middleField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "inner",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "inner",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "inner_list",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "innerList",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "InnerMessage",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "inner_field",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "innerField",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "deep",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "deep",
              proto3_optional: nil,
              __unknown_fields__: []
            }
          ],
          nested_type: [
            %Google.Protobuf.DescriptorProto{
              name: "DeepMessage",
              field: [
                %Google.Protobuf.FieldDescriptorProto{
                  name: "deep_field",
                  extendee: nil,
                  number: 1,
                  label: :LABEL_OPTIONAL,
                  type: :TYPE_STRING,
                  type_name: nil,
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "deepField",
                  proto3_optional: nil,
                  __unknown_fields__: []
                },
                %Google.Protobuf.FieldDescriptorProto{
                  name: "very_deep",
                  extendee: nil,
                  number: 2,
                  label: :LABEL_OPTIONAL,
                  type: :TYPE_MESSAGE,
                  type_name:
                    ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "veryDeep",
                  proto3_optional: nil,
                  __unknown_fields__: []
                }
              ],
              nested_type: [
                %Google.Protobuf.DescriptorProto{
                  name: "VeryDeepMessage",
                  field: [
                    %Google.Protobuf.FieldDescriptorProto{
                      name: "very_deep_field",
                      extendee: nil,
                      number: 1,
                      label: :LABEL_OPTIONAL,
                      type: :TYPE_STRING,
                      type_name: nil,
                      default_value: nil,
                      options: nil,
                      oneof_index: nil,
                      json_name: "veryDeepField",
                      proto3_optional: nil,
                      __unknown_fields__: []
                    },
                    %Google.Protobuf.FieldDescriptorProto{
                      name: "values",
                      extendee: nil,
                      number: 2,
                      label: :LABEL_REPEATED,
                      type: :TYPE_INT32,
                      type_name: nil,
                      default_value: nil,
                      options: nil,
                      oneof_index: nil,
                      json_name: "values",
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
              ],
              enum_type: [],
              extension_range: [],
              extension: [],
              options: nil,
              oneof_decl: [],
              reserved_range: [],
              reserved_name: [],
              __unknown_fields__: []
            }
          ],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: nil,
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: []
        }
      ],
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

  field :middle_field, 1, type: :string, json_name: "middleField"
  field :inner, 2, type: Nested.OuterMessage.MiddleMessage.InnerMessage

  field :inner_list, 3,
    repeated: true,
    type: Nested.OuterMessage.MiddleMessage.InnerMessage,
    json_name: "innerList"
end

defmodule Nested.OuterMessage.NestedMapEntry do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage.NestedMapEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NestedMapEntry",
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
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage",
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
        features: nil,
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

  field :key, 1, type: :string
  field :value, 2, type: Nested.OuterMessage.MiddleMessage
end

defmodule Nested.OuterMessage do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterMessage",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "OuterMessage",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "outer_field",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "outerField",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "middle",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "middle",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "middle_list",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "middleList",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "nested_map",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.NestedMapEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nestedMap",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "option_a",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "optionA",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "option_b",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "optionB",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "simple_option",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "simpleOption",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "MiddleMessage",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "middle_field",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "middleField",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "inner",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "inner",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "inner_list",
              extendee: nil,
              number: 3,
              label: :LABEL_REPEATED,
              type: :TYPE_MESSAGE,
              type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "innerList",
              proto3_optional: nil,
              __unknown_fields__: []
            }
          ],
          nested_type: [
            %Google.Protobuf.DescriptorProto{
              name: "InnerMessage",
              field: [
                %Google.Protobuf.FieldDescriptorProto{
                  name: "inner_field",
                  extendee: nil,
                  number: 1,
                  label: :LABEL_OPTIONAL,
                  type: :TYPE_STRING,
                  type_name: nil,
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "innerField",
                  proto3_optional: nil,
                  __unknown_fields__: []
                },
                %Google.Protobuf.FieldDescriptorProto{
                  name: "deep",
                  extendee: nil,
                  number: 2,
                  label: :LABEL_OPTIONAL,
                  type: :TYPE_MESSAGE,
                  type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
                  default_value: nil,
                  options: nil,
                  oneof_index: nil,
                  json_name: "deep",
                  proto3_optional: nil,
                  __unknown_fields__: []
                }
              ],
              nested_type: [
                %Google.Protobuf.DescriptorProto{
                  name: "DeepMessage",
                  field: [
                    %Google.Protobuf.FieldDescriptorProto{
                      name: "deep_field",
                      extendee: nil,
                      number: 1,
                      label: :LABEL_OPTIONAL,
                      type: :TYPE_STRING,
                      type_name: nil,
                      default_value: nil,
                      options: nil,
                      oneof_index: nil,
                      json_name: "deepField",
                      proto3_optional: nil,
                      __unknown_fields__: []
                    },
                    %Google.Protobuf.FieldDescriptorProto{
                      name: "very_deep",
                      extendee: nil,
                      number: 2,
                      label: :LABEL_OPTIONAL,
                      type: :TYPE_MESSAGE,
                      type_name:
                        ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage.VeryDeepMessage",
                      default_value: nil,
                      options: nil,
                      oneof_index: nil,
                      json_name: "veryDeep",
                      proto3_optional: nil,
                      __unknown_fields__: []
                    }
                  ],
                  nested_type: [
                    %Google.Protobuf.DescriptorProto{
                      name: "VeryDeepMessage",
                      field: [
                        %Google.Protobuf.FieldDescriptorProto{
                          name: "very_deep_field",
                          extendee: nil,
                          number: 1,
                          label: :LABEL_OPTIONAL,
                          type: :TYPE_STRING,
                          type_name: nil,
                          default_value: nil,
                          options: nil,
                          oneof_index: nil,
                          json_name: "veryDeepField",
                          proto3_optional: nil,
                          __unknown_fields__: []
                        },
                        %Google.Protobuf.FieldDescriptorProto{
                          name: "values",
                          extendee: nil,
                          number: 2,
                          label: :LABEL_REPEATED,
                          type: :TYPE_INT32,
                          type_name: nil,
                          default_value: nil,
                          options: nil,
                          oneof_index: nil,
                          json_name: "values",
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
                  ],
                  enum_type: [],
                  extension_range: [],
                  extension: [],
                  options: nil,
                  oneof_decl: [],
                  reserved_range: [],
                  reserved_name: [],
                  __unknown_fields__: []
                }
              ],
              enum_type: [],
              extension_range: [],
              extension: [],
              options: nil,
              oneof_decl: [],
              reserved_range: [],
              reserved_name: [],
              __unknown_fields__: []
            }
          ],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: nil,
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: []
        },
        %Google.Protobuf.DescriptorProto{
          name: "NestedMapEntry",
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
              type: :TYPE_MESSAGE,
              type_name: ".nested.OuterMessage.MiddleMessage",
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
            features: nil,
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
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "nested_oneof",
          options: nil,
          __unknown_fields__: []
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: []
    }
  end

  oneof :nested_oneof, 0

  field :outer_field, 1, type: :string, json_name: "outerField"
  field :middle, 2, type: Nested.OuterMessage.MiddleMessage

  field :middle_list, 3,
    repeated: true,
    type: Nested.OuterMessage.MiddleMessage,
    json_name: "middleList"

  field :nested_map, 4,
    repeated: true,
    type: Nested.OuterMessage.NestedMapEntry,
    json_name: "nestedMap",
    map: true

  field :option_a, 5, type: Nested.OuterMessage.MiddleMessage, json_name: "optionA", oneof: 0

  field :option_b, 6,
    type: Nested.OuterMessage.MiddleMessage.InnerMessage,
    json_name: "optionB",
    oneof: 0

  field :simple_option, 7, type: :string, json_name: "simpleOption", oneof: 0
end

defmodule Nested.OuterResponse do
  @moduledoc false

  use Protobuf,
    full_name: "nested.OuterResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "OuterResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "deep_result",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "deepResult",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "middle_results",
          extendee: nil,
          number: 2,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.OuterMessage.MiddleMessage",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "middleResults",
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

  field :deep_result, 1,
    type: Nested.OuterMessage.MiddleMessage.InnerMessage.DeepMessage,
    json_name: "deepResult"

  field :middle_results, 2,
    repeated: true,
    type: Nested.OuterMessage.MiddleMessage,
    json_name: "middleResults"
end

defmodule Nested.ComplexNested.Node.NamedChildrenEntry do
  @moduledoc false

  use Protobuf,
    full_name: "nested.ComplexNested.Node.NamedChildrenEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "NamedChildrenEntry",
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
          type: :TYPE_MESSAGE,
          type_name: ".nested.ComplexNested.Node",
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
        features: nil,
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

  field :key, 1, type: :string
  field :value, 2, type: Nested.ComplexNested.Node
end

defmodule Nested.ComplexNested.Node do
  @moduledoc false

  use Protobuf,
    full_name: "nested.ComplexNested.Node",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Node",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "type",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".nested.ComplexNested.Node.NodeType",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "type",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "children",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.ComplexNested.Node",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "children",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "parent",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.ComplexNested.Node",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "parent",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "named_children",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.ComplexNested.Node.NamedChildrenEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "namedChildren",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "NamedChildrenEntry",
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
              type: :TYPE_MESSAGE,
              type_name: ".nested.ComplexNested.Node",
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
            features: nil,
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
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "NodeType",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "LEAF",
              number: 0,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "BRANCH",
              number: 1,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "ROOT",
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

  field :id, 1, type: :string
  field :type, 2, type: Nested.ComplexNested.Node.NodeType, enum: true
  field :children, 3, repeated: true, type: Nested.ComplexNested.Node
  field :parent, 4, type: Nested.ComplexNested.Node

  field :named_children, 5,
    repeated: true,
    type: Nested.ComplexNested.Node.NamedChildrenEntry,
    json_name: "namedChildren",
    map: true
end

defmodule Nested.ComplexNested do
  @moduledoc false

  use Protobuf,
    full_name: "nested.ComplexNested",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ComplexNested",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "status",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".nested.ComplexNested.Status",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "status",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "root",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".nested.ComplexNested.Node",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "root",
          proto3_optional: nil,
          __unknown_fields__: []
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "all_nodes",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".nested.ComplexNested.Node",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "allNodes",
          proto3_optional: nil,
          __unknown_fields__: []
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "Node",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "id",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "id",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "type",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_ENUM,
              type_name: ".nested.ComplexNested.Node.NodeType",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "type",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "children",
              extendee: nil,
              number: 3,
              label: :LABEL_REPEATED,
              type: :TYPE_MESSAGE,
              type_name: ".nested.ComplexNested.Node",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "children",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "parent",
              extendee: nil,
              number: 4,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".nested.ComplexNested.Node",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "parent",
              proto3_optional: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "named_children",
              extendee: nil,
              number: 5,
              label: :LABEL_REPEATED,
              type: :TYPE_MESSAGE,
              type_name: ".nested.ComplexNested.Node.NamedChildrenEntry",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "namedChildren",
              proto3_optional: nil,
              __unknown_fields__: []
            }
          ],
          nested_type: [
            %Google.Protobuf.DescriptorProto{
              name: "NamedChildrenEntry",
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
                  type: :TYPE_MESSAGE,
                  type_name: ".nested.ComplexNested.Node",
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
                features: nil,
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
          enum_type: [
            %Google.Protobuf.EnumDescriptorProto{
              name: "NodeType",
              value: [
                %Google.Protobuf.EnumValueDescriptorProto{
                  name: "LEAF",
                  number: 0,
                  options: nil,
                  __unknown_fields__: []
                },
                %Google.Protobuf.EnumValueDescriptorProto{
                  name: "BRANCH",
                  number: 1,
                  options: nil,
                  __unknown_fields__: []
                },
                %Google.Protobuf.EnumValueDescriptorProto{
                  name: "ROOT",
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
      ],
      enum_type: [
        %Google.Protobuf.EnumDescriptorProto{
          name: "Status",
          value: [
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "UNKNOWN",
              number: 0,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "ACTIVE",
              number: 1,
              options: nil,
              __unknown_fields__: []
            },
            %Google.Protobuf.EnumValueDescriptorProto{
              name: "INACTIVE",
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

  field :status, 1, type: Nested.ComplexNested.Status, enum: true
  field :root, 2, type: Nested.ComplexNested.Node
  field :all_nodes, 3, repeated: true, type: Nested.ComplexNested.Node, json_name: "allNodes"
end

defmodule Nested.NestedService.Service do
  @moduledoc false

  use GRPC.Service, name: "nested.NestedService", protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "NestedService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ProcessNested",
          input_type: ".nested.OuterMessage",
          output_type: ".nested.OuterResponse",
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

  rpc :ProcessNested, Nested.OuterMessage, Nested.OuterResponse
end

defmodule Nested.NestedService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Nested.NestedService.Service
end

defmodule Nested.AnotherNestedService.Service do
  @moduledoc false

  use GRPC.Service, name: "nested.AnotherNestedService", protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "AnotherNestedService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "ProcessOuter",
          input_type: ".nested.OuterMessage",
          output_type: ".nested.OuterResponse",
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
          name: "ProcessMiddle",
          input_type: ".nested.OuterMessage.MiddleMessage",
          output_type: ".nested.OuterMessage.MiddleMessage",
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
          name: "ProcessInner",
          input_type: ".nested.OuterMessage.MiddleMessage.InnerMessage",
          output_type: ".nested.OuterMessage.MiddleMessage.InnerMessage",
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

  rpc :ProcessOuter, Nested.OuterMessage, Nested.OuterResponse

  rpc :ProcessMiddle, Nested.OuterMessage.MiddleMessage, Nested.OuterMessage.MiddleMessage

  rpc :ProcessInner,
      Nested.OuterMessage.MiddleMessage.InnerMessage,
      Nested.OuterMessage.MiddleMessage.InnerMessage
end

defmodule Nested.AnotherNestedService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Nested.AnotherNestedService.Service
end
