defmodule TestserviceV2.PbExtension do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.12.0"

  extend TestserviceV2.TestRequest, :extended_field, 10, optional: true, type: :string
end