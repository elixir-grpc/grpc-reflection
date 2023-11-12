ExUnit.start()

# include helloworld in tests
Application.put_env(:grpc_reflection, :services, [
  Helloworld.Greeter.Service,
  Grpc.Reflection.V1.ServerReflection.Service,
  Grpc.Reflection.V1alpha.ServerReflection.Service
])
