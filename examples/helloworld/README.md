# GrpcReflection helloworld

This example is mostly copied directly from `grpc-elixir`, with the exception that this example has:

1. Compiled protos with descriptors on.  This is required for the reflection service to run correctly
1. Is running the `GrpcReflection.Server` server in its endpoint
1. Configued the `GrpcReflection.Server` to include `helloworld` in its services

## Usage

1. Install deps and compile
```shell
$ mix do deps.get, compile
```

2. Compile protos
```shell
$ ./generate_protos.sh
```

3. Run the server
```shell
$ mix run --no-halt
```

4. Run the client script
```shell
$ mix run priv/client.exs
```

5. Explore the reflection services
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

## Regenerate Elixir code from proto

1. Modify the proto `priv/protos/helloworld.proto`
2. Install `protoc` [here](https://developers.google.com/protocol-buffers/docs/downloads)
3. Install `protoc-gen-elixir`
```
mix escript.install hex protobuf
```
4. Generate the code:
```shell
$ ./generate_protos.sh
```

Refer to [protobuf-elixir](https://github.com/tony612/protobuf-elixir#usage) for more information.

## How to start server when starting your application?

Pass `start_server: true` as an option for the `GRPC.Server.Supervisor` in your supervision tree.
