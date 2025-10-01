defmodule HLW.PbExtension do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1"

  extend HLW.TestRequest, :data, 10, optional: true, type: :string

  extend HLW.TestRequest, :location, 11, optional: true, type: HLW.Location
end
