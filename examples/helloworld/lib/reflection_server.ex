defmodule Helloworld.Reflection.Server do
  use GrpcReflection.Server,
    version: :v1,
    services: [Helloworld.Greeter.Service]
end
