# CHANGELOG

## Unreleased

### Bug fixes

- A message that refers to itself, or a nested type that refers back to its enclosing message, no longer makes its file depend on itself. Clients such as grpcurl overflowed their stack loading it https://github.com/elixir-grpc/grpc-reflection/issues/90 https://github.com/elixir-grpc/grpc-reflection/pull/91
- Nested messages and enums are served inside the file of the message that declares them, wherever they are referenced from (another message, a map value, an rpc request or response, or a cycle) and also when protos are compiled without descriptors. Before, clients failed with `cannot resolve type` https://github.com/elixir-grpc/grpc-reflection/issues/92
- Types used only by a message nested two or more levels deep are now listed as dependencies of its file
- A cycle that runs through a nested type is merged into one file like any other cycle, instead of leaving two files that depend on each other
- A file's package is no longer guessed from capitalization, so single letter and lowercase type names (`message A`, `message lower`) stay out of the package
- Nested types are found in modules generated before protoc-gen-elixir recorded `full_name`, from the enclosing message's descriptor. Referring to a nested type before its enclosing message no longer fails with `Symbols Conflict detected`
- A message with a proto2 `group` field no longer makes the reflection tree fail to build, which failed every reflection request
- Without descriptors, map entry messages are marked as map entries, so clients see `map<k, v>` fields as maps

### Enhancements

- A nested type that cannot be traced, and that nothing refers to, is left out of its file with a warning, so the file can still be loaded
- An error is logged for any file that depends on a file that was never built

### Internal

- Link-check the reflection tree built for every fixture service the way a client would (`GrpcReflection.GraphCheck`): dependencies exist, no cycles, every type resolves, every symbol is defined by its file
- The grpcurl graph walk in the tests follows types in snake_case packages and stops at types it already described
- New fixtures for nested types referenced across messages, cycles through nested types, deeply nested dependencies, and short type names

## v0.5.0 (2026-06-22)

### Enhancements

- Support `grpc` 1.0, which split the server into the separate `grpc_server` package. Depend on both `grpc ~> 1.0` (client/`GRPC.Stub`, used by the generated reflection stubs) and `grpc_server ~> 1.0` (`GRPC.Server`/`GRPC.Endpoint`).

### Internal

- Drop the obsolete `start_supervised({GRPC.Client.Supervisor, []})` calls from the test support — `grpc` 1.0 starts the client supervisor automatically via its application, and the module is no longer a valid child spec. Add `gun` as a test-only dependency since the HTTP client adapters are now optional in `grpc` 1.0.
- updated to protobuf 0.17.0 and regenerated pb files

## v0.4.0 (2026-05-05)

### Enhancements

- Add descriptor synthesizer as a fallback for services compiled without `use GRPC.Server, descriptor?: true` — reflection now works even when no file descriptor is present (#84)
- Add support for recursive message types, preventing infinite loops during symbol resolution (#82)
- Improve resolution of deeply nested message types (#83)

### Internal

- Overhaul test suite with representative `.proto` definitions and generated `.pb.ex` fixtures, replacing ad-hoc test services with a comprehensive set of cases covering scalar types, well-known types, streaming, imports, cross-package refs, proto2 features, edge cases, and more (#72)

## v0.3.3 (2026-04-13)

Move debug log from `info` to `debug` log levels

## v0.3.2 (2026-04-12)

Update protobuf dependency and fix warnings

## v0.3.1 (2026-03-04)

### Bug fixes

- relax dependency to allow newer package usage https://github.com/elixir-grpc/grpc-reflection/pull/73
- Handle nested enums instead of synthesizing them as standalone messages https://github.com/elixir-grpc/grpc-reflection/pull/74

## v0.3.0 (2025-11-26)

Update to newer upstream grpc library

## v0.2.0 (2025-06-18)

### Bug fixes

- https://github.com/elixir-grpc/grpc-reflection/issues/53

### Enhancements

- Reflection tree builder refactored to match grpc symbols against GRPC-exposed module names
