# GrpcReflection

[![GitHub CI](https://github.com/elixir-grpc/grpc-reflection/actions/workflows/ci.yml/badge.svg)](https://github.com/elixir-grpc/grpc-reflection/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/grpc_reflection.svg)](https://hex.pm/packages/grpc_reflection)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/grpc_reflection/)
[![License](https://img.shields.io/hexpm/l/grpc_reflection.svg)](https://github.com/elixir-grpc/grpc-reflection/blob/main/LICENSE)
[![Total Downloads](https://img.shields.io/hexpm/dt/grpc_reflection.svg)](https://hex.pm/packages/grpc_reflection)

Server reflection allows servers to assist clients in runtime construction of requests without having stub information precompiled into the client.

According to the [GRPC Server Reflection Protocol
](https://github.com/grpc/grpc/blob/master/doc/server-reflection.md), the primary usecase for server reflection is to write (typically) command line debugging tools for talking to a grpc server. In particular, such a tool will take in a method and a payload (in human readable text format) send it to the server (typically in binary proto wire format), and then take the response and decode it to text to present to the user.

GrpcReflection adds reflection support to applications built with [grpc-elixir](https://hex.pm/packages/grpc). It is a supervised application that can be implemented as a gRPC server using [grpc-elixir](https://github.com/elixir-grpc/grpc).

## Installation

The package can be installed by adding `grpc_reflection` to your list of dependencies in `mix.exs`:

```elixir
{:grpc_reflection, "~> 0.2"}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/grpc_reflection>.

# Reflection

This is written and tested using [grpcurl](https://github.com/fullstorydev/grpcurl) and [postman](https://www.postman.com). It supports both v1alpha and v1 reflection by using one or both of the provided servers: `rpcReflection.V1.Server` or `rpcReflection.V1alpha.Server`

## Enable reflection on your application

1. Rebuild your protos with descriptors enabled. Each module and/or service that you would like to expose through reflection must use the protoc elixir-out option `gen_descriptors=true`.

1. Create a reflection server

   ```elixir
   defmodule Helloworld.Reflection.Server do
     use GrpcReflection.Server,
       version: :v1,
       services: [Helloworld.Greeter.Service]
   end
   ```

   | Config Option | Description                                                             |
   | :-----------: | ----------------------------------------------------------------------- |
   |   `version`   | Either `:v1` or `:v1alpha`, depending on intended client support.       |
   |  `services`   | This is a list of GRPC services that should be included for reflection. |

   > [!CAUTION]
   > Multiple services are combined into a single reflection state. If fully-qualified symbol names collide for different payloads in those different services, one of the symbols will be overwritten by the other. Please ensure services and messages are namespaced properly to scope your messages; and be mindful of services that may rely on different versions of external proto dependencies.

1. Add the reflection supervisor to your supervision tree to host the cached reflection state

   ```elixir
   children = [
     ...other children,
     GrpcReflection
   ]
   ```

1. Add your servers to your grpc endpoint

   ```elixir
     run(Helloworld.Reflection.Server)
   ```

Reflection calls can now be made on your existing endpoint, on its existing configured port

## Interacting with your reflection server

List services that can be reflected:

```bash
$ grpcurl -v -plaintext 127.0.0.1:50051 list
helloworld.Greeter
```

List calls that are exposed by a service:

```bash
$ grpcurl -v -plaintext 127.0.0.1:50051 list helloworld.Greeter
helloworld.Greeter.SayHello
```

Get information about a call on a service

```bash
$ grpcurl -v -plaintext 127.0.0.1:50051 describe helloworld.Greeter.SayHello
helloworld.Greeter.SayHello is a method:
rpc SayHello ( .helloworld.HelloRequest ) returns ( .helloworld.HelloReply );
```

Get information about a named type used in a call on a servce:

```bash
$ grpcurl -v -plaintext 127.0.0.1:50051 describe .helloworld.HelloReply
helloworld.HelloReply is a message:
message HelloReply {
  optional string message = 1;
  optional .google.protobuf.Timestamp today = 2;
}
```

Execute a call using grpcurl that leverages reflection to fill in the gaps and generate an encoded request, and decoding the response.

```bash
$ grpcurl -plaintext -format text -d 'name: "faker"' localhost:50051 helloworld.Greeter.SayHello
message: "Hello faker"
today: <
  seconds:1708412184 nanos:671267628
>
```

## Protobuf Version Support

This module is more thoroughly tested with proto3, but it has some testing with proto2. In either case feedback is appreciated as we approach full proto support in this module.

## Application Support

This is **not** an exhaustive list, contributions are appreciated.

| Application                                        | Reflection version required |
| -------------------------------------------------- | :-------------------------: |
| [grpcurl](https://github.com/fullstorydev/grpcurl) |             V1              |
| [grpcui](https://github.com/fullstorydev/grpcui)   |             V1              |
| [postman](https://www.postman.com/)                |           V1alpha           |
