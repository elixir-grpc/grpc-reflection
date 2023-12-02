defmodule Helloworld.Reflection.Server do
  use GrpcReflection,
    version: :v1,
    name: :v1_store,
    services: [Helloworld.Greeter.Service]
end
