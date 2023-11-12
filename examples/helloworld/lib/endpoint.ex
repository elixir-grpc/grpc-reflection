defmodule Helloworld.Endpoint do
  use GRPC.Endpoint

  intercept(GRPC.Server.Interceptors.Logger)
  run(Helloworld.Greeter.Server)

  run(GrpcReflection.V1AlphaServer)
  run(GrpcReflection.V1Server)
end
