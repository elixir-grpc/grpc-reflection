defmodule NoDescriptor.PackageB.MessageB do
  @moduledoc false

  use Protobuf,
    full_name: "package_b.MessageB",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :field_b, 1, type: :string, json_name: "fieldB"
  field :message_from_a, 2, type: PackageA.MessageA, json_name: "messageFromA"
  field :enum_from_a, 3, type: PackageA.EnumA, json_name: "enumFromA", enum: true
end

defmodule NoDescriptor.PackageB.ResponseB do
  @moduledoc false

  use Protobuf,
    full_name: "package_b.ResponseB",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :results, 1, repeated: true, type: PackageA.MessageA
end

defmodule NoDescriptor.PackageB.ServiceB.Service do
  @moduledoc false

  use GRPC.Service, name: "package_b.ServiceB", protoc_gen_elixir_version: "0.16.0"

  rpc :ProcessB, NoDescriptor.PackageB.MessageB, NoDescriptor.PackageB.ResponseB

  rpc :ProcessA, PackageA.MessageA, PackageA.MessageA
end

defmodule NoDescriptor.PackageB.ServiceB.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.PackageB.ServiceB.Service
end
