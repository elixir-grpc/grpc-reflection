defmodule GrpcReflection.TestEndpoint do
  defmodule V1Server do
    use GrpcReflection,
      version: :v1,
      services: [
        Helloworld.Greeter.Service,
        TestserviceV3.TestService.Service,
        Grpc.Reflection.V1.ServerReflection.Service,
        Grpc.Reflection.V1alpha.ServerReflection.Service
      ]
  end

  defmodule V1Server.Stub do
    use GRPC.Stub, service: Grpc.Reflection.V1.ServerReflection.Service
  end

  defmodule V1AlphaServer do
    use GrpcReflection,
      version: :v1alpha,
      services: [
        Helloworld.Greeter.Service,
        TestserviceV3.TestService.Service,
        Grpc.Reflection.V1.ServerReflection.Service,
        Grpc.Reflection.V1alpha.ServerReflection.Service
      ]
  end

  defmodule V1AlphaServer.Stub do
    use GRPC.Stub, service: Grpc.Reflection.V1alpha.ServerReflection.Service
  end

  defmodule Endpoint do
    use GRPC.Endpoint

    run(Helloworld.Greeter.Server)
    run(V1Server)
    run(V1AlphaServer)
  end
end
