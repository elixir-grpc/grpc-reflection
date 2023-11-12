# GrpcReflection

GrpcReclection is a grpc server built using `grpc-elixir`.  This server adds grpc reflection support to a `grpc-elixir` based application.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `grpc_reflection` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:grpc_reflection, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/grpc_reflection>.

# Reflection

This is written and tested using grpcurl and postman.  It supports both v1alpha and v1 reflection by using one or both of the provided servers: `rpcReflection.V1.Server` or `rpcReflection.V1alpha.Server`

## Enable reflection on your application

1. Rebuild your protos with descriptors on.  Each module and/or service that you would like to expose through reflection must use the protoc elixir-out option `gen_descriptors=true`
1. Add `run(GrpcReflection.Server.V1)` and/or `run(GrpcReflection.Server.V1alpha)`  to your grpc endpoint
1. Configure reflection for your services ```
config :grpc_reflection, services: [
  Helloworld.Greeter.Service, 
  Grpc.Reflection.V1.ServerReflection.Service,
  Grpc.Reflection.V1alpha.ServerReflection.Service]
```

## interacting with your reflection

Here are some example `grpcurl` commands and responses excersizing the reflection capabilities

```shell
$ grpcurl -v -plaintext 127.0.0.1:50051 list
grpc.reflection.v1.ServerReflection
helloworld.Greeter

$ grpcurl -v -plaintext 127.0.0.1:50051 list helloworld.Greeter
helloworld.Greeter.SayHello

$ grpcurl -v -plaintext 127.0.0.1:50051 describe helloworld.Greeter.SayHello
helloworld.Greeter.SayHello is a method:
rpc SayHello ( .helloworld.HelloRequest ) returns ( .helloworld.HelloReply );

$ grpcurl -v -plaintext 127.0.0.1:50051 describe .helloworld.HelloReply
helloworld.HelloReply is a message:
message HelloReply {
  optional string message = 1;
  optional .google.protobuf.Timestamp today = 2;
}
```