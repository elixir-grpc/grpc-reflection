defmodule EmptyService.EmptyService.Service do
  @moduledoc false

  use GRPC.Service, name: "empty_service.EmptyService", protoc_gen_elixir_version: "0.16.0"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "EmptyService",
      method: [],
      options: nil,
      __unknown_fields__: []
    }
  end
end

defmodule EmptyService.EmptyService.Stub do
  @moduledoc false

  use GRPC.Stub, service: EmptyService.EmptyService.Service
end
