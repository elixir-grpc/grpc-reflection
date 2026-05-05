defmodule NoDescriptor.Common.Priority do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "common.Priority",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :PRIORITY_UNSPECIFIED, 0
  field :LOW, 1
  field :MEDIUM, 2
  field :HIGH, 3
  field :CRITICAL, 4
end

defmodule NoDescriptor.Common.Address do
  @moduledoc false

  use Protobuf, full_name: "common.Address", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :street, 1, type: :string
  field :city, 2, type: :string
  field :state, 3, type: :string
  field :postal_code, 4, type: :string, json_name: "postalCode"
  field :country, 5, type: :string
end

defmodule NoDescriptor.Common.Coordinates do
  @moduledoc false

  use Protobuf,
    full_name: "common.Coordinates",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :latitude, 1, type: :double
  field :longitude, 2, type: :double
  field :altitude, 3, type: :double
end

defmodule NoDescriptor.Common.Money do
  @moduledoc false

  use Protobuf, full_name: "common.Money", protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :currency_code, 1, type: :string, json_name: "currencyCode"
  field :units, 2, type: :int64
  field :nanos, 3, type: :int32
end

defmodule NoDescriptor.Common.TimeRange do
  @moduledoc false

  use Protobuf,
    full_name: "common.TimeRange",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :start_time, 1, type: :int64, json_name: "startTime"
  field :end_time, 2, type: :int64, json_name: "endTime"
end
