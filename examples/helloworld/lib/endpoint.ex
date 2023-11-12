defmodule Helloworld.Endpoint do
  use GRPC.Endpoint

  intercept(GRPC.Server.Interceptors.Logger)
  run(Helloworld.Greeter.Server)

  run(GrpcReflection.Server.V1alpha)
  run(GrpcReflection.Server.V1)
end
