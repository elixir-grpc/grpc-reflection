# GrpcReflection

**TODO: Add description**

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

this is written and tested using grpcurl

## list services
`grpcurl -plaintext 127.0.0.1:50051 list`

## list calls for a service
`grpcurl -plaintext 127.0.0.1:50051 list helloworld.Greeter`

## describing elements
`grpcurl -plaintext 127.0.0.1:50051 describe helloworld.Greeter.SayHello`