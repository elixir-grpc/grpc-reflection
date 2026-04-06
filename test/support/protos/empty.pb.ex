defmodule Empty.EmptyService.Service do
  @moduledoc false

  use GRPC.Service, name: "empty.EmptyService", protoc_gen_elixir_version: "0.16.0"

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

defmodule Empty.EmptyService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Empty.EmptyService.Service
end
