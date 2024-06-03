defmodule Helloworld.Reflection.Server do
  use GrpcReflection.Server,
    version: :v1,
    services: [Example.Helloworld.Greeter.Service]
end
