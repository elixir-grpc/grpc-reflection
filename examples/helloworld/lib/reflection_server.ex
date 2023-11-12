defmodule Helloworld.Reflection.Server do
  use GrpcReflection.Server, services: [Helloworld.Greeter.Service]
end
