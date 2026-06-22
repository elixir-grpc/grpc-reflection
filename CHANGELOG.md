# CHANGELOG

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
