defmodule GrpcReflection.Service.Builder do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.State
  alias GrpcReflection.Service.Builder.Util
  alias GrpcReflection.Service.Builder.Extensions

  def build_reflection_tree(services) do
    with :ok <- Util.validate_services(services) do
      tree =
        Enum.reduce(services, State.new(services), fn service, state ->
          new_state = process_service(service)
          State.merge(state, new_state)
        end)

      {:ok, tree}
    end
  end

  defp process_service(service) do
    service_name = service.__meta__(:name)
    service_response = build_response(service_name, service)

    State.new()
    |> State.add_symbols(%{service_name => service_response})
    |> State.add_files(%{(service_name <> ".proto") => service_response})
    |> trace_service_refs(service)
  end

  defp trace_service_refs(state, module) do
    service_name = module.__meta__(:name)
    methods = get_descriptor(module).method

    module.__rpc_calls__()
    |> Enum.reduce(state, fn call, state ->
      {function, {request, _}, {response, _}, _} = call

      %{input_type: req_symbol, output_type: resp_symbol} =
        Enum.find(methods, fn method -> method.name == to_string(function) end)

      call_symbol = service_name <> "." <> to_string(function)
      call_response = build_response(service_name, module)
      req_symbol = Util.trim_symbol(req_symbol)
      req_response = build_response(req_symbol, request)
      resp_symbol = Util.trim_symbol(resp_symbol)
      resp_response = build_response(resp_symbol, response)

      state
      |> Extensions.add_extensions(service_name, module)
      |> State.add_symbols(%{
        call_symbol => call_response,
        req_symbol => req_response,
        resp_symbol => resp_response
      })
      |> State.add_files(%{
        (req_symbol <> ".proto") => req_response,
        (resp_symbol <> ".proto") => resp_response
      })
      |> Extensions.add_extensions(req_symbol, request)
      |> Extensions.add_extensions(resp_symbol, response)
      |> trace_message_refs(req_symbol, request)
      |> trace_message_refs(resp_symbol, response)
    end)
  end

  defp trace_message_refs(state, parent_symbol, module) do
    case module.descriptor() do
      %{field: fields} ->
        trace_message_fields(state, parent_symbol, module, fields)

      _ ->
        state
    end
  end

  defp trace_message_fields(state, parent_symbol, module, fields) do
    # nested types arent a "separate file", they return their parents' response
    nested_types = Util.get_nested_types(parent_symbol, module.descriptor())

    module.__message_props__().field_props
    |> Map.values()
    |> Enum.map(fn %{name: name, type: type} ->
      %{
        mod:
          case type do
            {_, mod} -> mod
            mod -> mod
          end,
        symbol: Enum.find(fields, fn f -> f.name == name end).type_name
      }
    end)
    |> Enum.reject(fn %{symbol: s} -> s == nil end)
    |> Enum.reduce(state, fn %{mod: mod, symbol: symbol}, state ->
      symbol = Util.trim_symbol(symbol)

      response =
        if symbol in nested_types do
          build_response(parent_symbol, module)
        else
          build_response(symbol, mod)
        end

      state
      |> Extensions.add_extensions(symbol, mod)
      |> State.add_symbols(%{symbol => response})
      |> State.add_files(%{(symbol <> ".proto") => response})
      |> trace_message_refs(symbol, mod)
    end)
  end

  defp build_response(symbol, module) do
    # we build our own file responses, so unwrap any present
    descriptor = get_descriptor(module)

    dependencies =
      descriptor
      |> Util.types_from_descriptor()
      |> Enum.uniq()
      |> Kernel.--(Util.get_nested_types(symbol, descriptor))
      |> Enum.map(fn name ->
        Util.trim_symbol(name) <> ".proto"
      end)

    syntax = Util.get_syntax(module)

    response_stub =
      %FileDescriptorProto{
        name: symbol <> ".proto",
        package: Util.get_package(symbol),
        dependency: dependencies,
        syntax: syntax
      }

    unencoded_payload =
      case descriptor = descriptor do
        %Google.Protobuf.DescriptorProto{} -> %{response_stub | message_type: [descriptor]}
        %Google.Protobuf.ServiceDescriptorProto{} -> %{response_stub | service: [descriptor]}
        %Google.Protobuf.EnumDescriptorProto{} -> %{response_stub | enum_type: [descriptor]}
      end

    %{file_descriptor_proto: [FileDescriptorProto.encode(unencoded_payload)]}
  end

  # protoc with the elixir generator and protobuf.generate slightly differ for how they
  # generate descriptors.  Use this to potentially unwrap the service proto when dealing
  # with descriptors that could come from a service module.
  defp get_descriptor(module) do
    case module.descriptor() do
      %FileDescriptorProto{service: [proto]} -> proto
      proto -> proto
    end
  end
end
