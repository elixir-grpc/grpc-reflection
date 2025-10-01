defmodule EmptyService.Service do
  @moduledoc false

  use GRPC.Service, name: "EmptyService", protoc_gen_elixir_version: "0.14.1"

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

defmodule EmptyService.Stub do
  @moduledoc false

  use GRPC.Stub, service: EmptyService.Service
end
