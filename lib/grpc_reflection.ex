defmodule GrpcReflection do
  @moduledoc """
  Reflection support for the grpc-elixir package

  To use these servers, all protos must be comppiled with the `gen_descriptors=true` option, as that is the source of truth for the reflection service.

  To turn on reflection in your application, do the following:

  1. Add one or both of the refleciton servers to your grpc endpoing
  ```
  run(GrpcReflection.V1alpha.Server)
  run(GrpcReflection.V1.Server)
  ```

  1. Configure grpc_reflection for the services you want to include in the `list_services` resposne
  ```
  config :grpc_reflection, services: [<Your service module>, <another service module>, <maybe reflection service?>]
  ```

  This service will return reflection data for any module that defined `descriptor()` when its module name is provided, with the following caveat:
  `protoc` using the grpc-elixir plugin will only downcase the first letter for the grpc symbpl  So Helloworld.HelloReply becomes helloworld.HelloReply.  This does not perform a case-insensitive search, but only upcases the first letter of each "."-separated word.  So the provided symbol must match that pattern, and then`descriptor` returns the grpc structs, or no response will be returned
  """
end
