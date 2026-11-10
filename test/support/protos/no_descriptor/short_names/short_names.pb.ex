defmodule NoDescriptor.ShortNames.A do
  @moduledoc false

  use Protobuf,
    full_name: "short_names.A",
    proto_source: "short_names.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :b, 1, type: NoDescriptor.ShortNames.B
  field :lower, 2, type: NoDescriptor.ShortNames.Lower
end

defmodule NoDescriptor.ShortNames.B do
  @moduledoc false

  use Protobuf,
    full_name: "short_names.B",
    proto_source: "short_names.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :value, 1, type: :string
end

defmodule NoDescriptor.ShortNames.Lower do
  @moduledoc false

  use Protobuf,
    full_name: "short_names.lower",
    proto_source: "short_names.proto",
    protoc_gen_elixir_version: "0.17.0",
    syntax: :proto3

  field :value, 1, type: :string
end

defmodule NoDescriptor.ShortNames.Service.Service do
  @moduledoc false

  use GRPC.Service, name: "short_names.Service", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "short_names.proto"

  rpc :call, NoDescriptor.ShortNames.A, NoDescriptor.ShortNames.B
end

defmodule NoDescriptor.ShortNames.Service.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.ShortNames.Service.Service
end
