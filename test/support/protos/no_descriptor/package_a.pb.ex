defmodule NoDescriptor.PackageA.EnumA do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "package_a.EnumA",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :ENUM_A_UNSPECIFIED, 0
  field :OPTION_1, 1
  field :OPTION_2, 2
end

defmodule NoDescriptor.PackageA.MessageA do
  @moduledoc false

  use Protobuf,
    full_name: "package_a.MessageA",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :field_a, 1, type: :string, json_name: "fieldA"
  field :count, 2, type: :int32
end
