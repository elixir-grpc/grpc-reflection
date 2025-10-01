defmodule TestserviceV2.PbExtension do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1"

  extend TestserviceV2.TestRequest, :data, 10, optional: true, type: :string

  extend TestserviceV2.TestRequest, :location, 11, optional: true, type: TestserviceV2.Location
end
