defmodule GrpcReflection.Service.Builder.Synthesizer do
  @moduledoc false

  # Builds a FieldDescriptorProto from a Protobuf.FieldProps.
  # Note: oneof_index is NOT set here for proto3_optional fields — those synthetic
  # oneof indices are assigned in message_descriptor/1 where all fields are visible.
  # syntax must be passed explicitly when building from message context; proto3 repeated
  # scalars have packed?: true in FieldProps but must NOT set options.packed (implicit).
  def field_descriptor_from_props(%Protobuf.FieldProps{} = props, syntax \\ :proto2) do
    {type, type_name} = resolve_type(props)

    %Google.Protobuf.FieldDescriptorProto{
      name: props.name,
      number: props.fnum,
      json_name: props.json_name,
      type: type,
      type_name: type_name,
      label: resolve_label(props),
      default_value: encode_default(props.default),
      oneof_index: props.oneof,
      options: field_options(props, syntax),
      proto3_optional: props.proto3_optional?,
      extendee: nil
    }
  end

  def message_descriptor(module) do
    props = module.__message_props__()

    fields =
      props.ordered_tags
      |> Enum.map(&props.field_props[&1])
      |> Enum.map(&field_descriptor_from_props(&1, props.syntax))
      |> assign_proto3_optional_oneof_indices(length(props.oneof))

    real_oneof_decls =
      Enum.map(props.oneof, fn {name, _tag} ->
        %Google.Protobuf.OneofDescriptorProto{name: Atom.to_string(name)}
      end)

    synthetic_oneof_decls =
      fields
      |> Enum.filter(& &1.proto3_optional)
      |> Enum.map(fn f ->
        %Google.Protobuf.OneofDescriptorProto{name: "_#{f.name}"}
      end)

    extension_ranges =
      (props.extension_range || [])
      |> Enum.map(fn {start, stop} ->
        %Google.Protobuf.DescriptorProto.ExtensionRange{start: start, end: stop}
      end)

    short_name = module.full_name() |> String.split(".") |> List.last()

    %Google.Protobuf.DescriptorProto{
      name: short_name,
      field: fields,
      oneof_decl: real_oneof_decls ++ synthetic_oneof_decls,
      extension_range: extension_ranges,
      nested_type: [],
      enum_type: []
    }
  end

  def enum_descriptor(module) do
    short_name = module.full_name() |> String.split(".") |> List.last()

    # mapping() is a map so has no intrinsic order; __message_props__.ordered_tags is
    # numerically sorted. Neither preserves proto declaration order, so we sort by value.
    # This differs from protoc output for enums with non-monotonic declaration order
    # (e.g. negative sentinel values declared after positive ones), but reflection
    # clients look up enum values by number, not position, so this is safe in practice.
    values =
      module.__message_props__().ordered_tags
      |> Enum.map(fn tag ->
        props = module.__message_props__().field_props[tag]
        %Google.Protobuf.EnumValueDescriptorProto{name: props.name, number: props.fnum}
      end)

    %Google.Protobuf.EnumDescriptorProto{name: short_name, value: values}
  end

  def service_descriptor(module) do
    service_name = module.__meta__(:name) |> String.split(".") |> List.last()

    methods =
      module.__rpc_calls__()
      |> Enum.map(fn
        {method, {req, req_stream}, {resp, resp_stream}} ->
          build_method_descriptor(method, req, req_stream, resp, resp_stream)

        {method, {req, req_stream}, {resp, resp_stream}, _opts} ->
          build_method_descriptor(method, req, req_stream, resp, resp_stream)
      end)

    %Google.Protobuf.ServiceDescriptorProto{name: service_name, method: methods}
  end

  defp resolve_label(%Protobuf.FieldProps{required?: true}), do: :LABEL_REQUIRED
  defp resolve_label(%Protobuf.FieldProps{repeated?: true}), do: :LABEL_REPEATED
  defp resolve_label(%Protobuf.FieldProps{map?: true}), do: :LABEL_REPEATED
  defp resolve_label(_), do: :LABEL_OPTIONAL

  defp resolve_type(%Protobuf.FieldProps{enum?: true, type: {:enum, mod}}) do
    {:TYPE_ENUM, "." <> mod.full_name()}
  end

  defp resolve_type(%Protobuf.FieldProps{embedded?: true, type: mod}) when is_atom(mod) do
    {:TYPE_MESSAGE, "." <> mod.full_name()}
  end

  defp resolve_type(%Protobuf.FieldProps{type: type}) do
    {:"TYPE_#{type |> Atom.to_string() |> String.upcase()}", nil}
  end

  # proto3 repeated scalars are implicitly packed — reflection clients infer this from
  # syntax, so options.packed must not be set (matches real protoc output).
  defp field_options(%Protobuf.FieldProps{packed?: true}, :proto2),
    do: %Google.Protobuf.FieldOptions{packed: true}

  defp field_options(_, _), do: nil

  defp encode_default(nil), do: nil
  defp encode_default(v) when is_binary(v), do: v
  defp encode_default(v) when is_boolean(v), do: to_string(v)
  defp encode_default(v) when is_integer(v), do: Integer.to_string(v)
  defp encode_default(v) when is_float(v), do: Float.to_string(v)
  defp encode_default(v) when is_atom(v), do: Atom.to_string(v)

  # proto3_optional fields have no oneof in __message_props__ (the runtime doesn't need
  # the synthetic oneof) but the wire format and reflection clients expect oneof_index to
  # point at a synthetic "_fieldname" oneof entry appended after any real oneofs.
  defp assign_proto3_optional_oneof_indices(fields, real_oneof_count) do
    fields
    |> Enum.map_reduce(0, fn field, counter ->
      if field.proto3_optional do
        {%{field | oneof_index: real_oneof_count + counter}, counter + 1}
      else
        {field, counter}
      end
    end)
    |> elem(0)
  end

  defp build_method_descriptor(method, req, req_stream, resp, resp_stream) do
    %Google.Protobuf.MethodDescriptorProto{
      name: method |> Atom.to_string() |> Macro.camelize(),
      input_type: "." <> req.full_name(),
      output_type: "." <> resp.full_name(),
      client_streaming: req_stream,
      server_streaming: resp_stream
    }
  end
end
