defmodule Helloworld.Reflection.Server do
  use GrpcReflection,
    version: :v1,
    services: [Helloworld.Greeter.Service]
end
