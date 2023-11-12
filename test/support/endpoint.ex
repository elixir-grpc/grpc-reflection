defmodule GrpcReflection.TestEndpoint do
  defmodule ReflectionServer do
    use GRPC.Server, service: Helloworld.Greeter.Service

    def say_hello(_request, _stream), do: %Helloworld.HelloReply{}
  end

  defmodule ReflectionServer.Stub do
    use GRPC.Stub, service: Helloworld.Greeter.Service
  end

  defmodule Endpoint do
    use GRPC.Endpoint

    run(Helloworld.Greeter.Server)
    run(GrpcReflection.Server.V1)
    run(GrpcReflection.Server.V1alpha)
  end
end
