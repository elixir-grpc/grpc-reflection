ExUnit.start()

# include helloworld in tests
Application.put_env(:grpc_reflection, :services, [Helloworld.Greeter.Service])
