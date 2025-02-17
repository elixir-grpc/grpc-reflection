# GrpcReflection

Server reflection allows servers to assist clients in runtime construction of requests without having stub information precompiled into the client.

According to the [GRPC Server Reflection Protocol
](https://github.com/grpc/grpc/blob/master/doc/server-reflection.md), the primary usecase for server reflection is to write (typically) command line debugging tools for talking to a grpc server. In particular, such a tool will take in a method and a payload (in human readable text format) send it to the server (typically in binary proto wire format), and then take the response and decode it to text to present to the user.

GrpcReflection, implemented as a gRPC server using `grpc-elixir`, adds reflection support to a `grpc-elixir`  based application.

## Installation

The package can be installed by adding `grpc_reflection` to your list of dependencies in `mix.exs`:

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

This is written and tested using [grpcurl](https://github.com/fullstorydev/grpcurl) and postman.  It supports both v1alpha and v1 reflection by using one or both of the provided servers: `rpcReflection.V1.Server` or `rpcReflection.V1alpha.Server`

## Enable reflection on your application

1. Rebuild your protos with descriptors on.  Each module and/or service that you would like to expose through reflection must use the protoc elixir-out option `gen_descriptors=true`
1. Create a reflection server
  ```elixir
  defmodule Helloworld.Reflection.Server do
    use GrpcReflection.Server,
      version: :v1,
      services: [Helloworld.Greeter.Service]
  end
  ```
  or
  ```elixir
  defmodule Helloworld.Reflection.Server2 do
    use GrpcReflection.Server,
      version: :v1alpha,
      services: [Helloworld.Greeter.Service]
  end
  ```
  or both as desired.  `version` is the grpc reflection spec, which can be `v1` or `v1alpha`.  `services` is the services that will be exposed by that server by reflection.  You can expose a service through both services if desired.
1. Add the reflection supervisor to your supervision tree to host the cached reflection state
```elixir
children = [
  ...other children,
  GrpcReflection
]
```
1. Add your servers to your grpc endpoint

## interacting with your reflection server

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

$ grpcurl -plaintext -format text -d 'name: "faker"' localhost:50051 helloworld.Greeter.SayHello
message: "Hello faker"
today: <
  seconds:1708412184 nanos:671267628 
>
```

## Protobuf Version Support

This module is more thoroughly tested with proto3, but it has some testing with proto2.  In either case feedback is appreciated as we approach full proto support in this module.

## Application Support

This is **not** an exhaustive list, contributions are appreciated.

| Application  | Reflection version required |
| ------------- | ------------- |
| grpcurl  | V1  |
| postman | V1alpha  |
