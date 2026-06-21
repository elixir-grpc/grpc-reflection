defmodule EmptyService.EmptyService.Service do
  @moduledoc false

  use GRPC.Service, name: "empty_service.EmptyService", protoc_gen_elixir_version: "0.17.0"

  def proto_source(), do: "empty_service.proto"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "EmptyService",
      method: [],
      options: nil,
      __unknown_fields__: [],
      __protobuf__: true
    }
  end
end

defmodule EmptyService.EmptyService.Stub do
  @moduledoc false

  use GRPC.Stub, service: EmptyService.EmptyService.Service
end
