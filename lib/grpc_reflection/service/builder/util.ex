defmodule GrpcReflection.Service.Builder.Util do
  @moduledoc """
  Utility functions for the builder.
  """
  @field_type_mapping Google.Protobuf.FieldDescriptorProto.Type.mapping()
  @field_label_mapping Google.Protobuf.FieldDescriptorProto.Label.mapping()

  @type_message Map.fetch!(Google.Protobuf.FieldDescriptorProto.Type.mapping(), :TYPE_MESSAGE)

  def get_nested_types(symbol, descriptor), do: get_nested_types(symbol, descriptor, [])

  def get_nested_types(_symbol, %Google.Protobuf.DescriptorProto{nested_type: []}, acc) do
    acc
  end

  def get_nested_types(symbol, %Google.Protobuf.DescriptorProto{nested_type: nested_types}, acc) do
    Enum.reduce(nested_types, acc, fn nested_type, acc ->
      new_symbol = symbol <> "." <> nested_type.name
      new_acc = [new_symbol | acc]
      get_nested_types(new_symbol, nested_type, new_acc)
    end)
  end

  def get_nested_types(_, _, acc), do: acc

  def get_package(symbol) do
    # assuming this symbol follows normal GRPC practices, Types are capilatized
    #
    # So if we split on "." and drop anything capitalized we arrive at the package name

    symbol
    |> String.split(".")
    |> Enum.reject(fn s -> Regex.match?(~r/^[A-Z].+/, s) end)
    |> Enum.join(".")
  end

  def downcase_first(<<first::utf8, rest::binary>>),
    do: String.downcase(<<first::utf8>>) <> rest

  # Generates a field descriptor from a field props struct. This function is compatible with proto2 only.
  def convert_to_field_descriptor(
        extendee,
        %Protobuf.Extension.Props.Extension{field_props: field_props}
      ) do
    {type, type_name} = type_from_field_props(field_props)

    %Google.Protobuf.FieldDescriptorProto{
      name: field_props.name,
      number: field_props.fnum,
      label: label_from_field_props(field_props),
      type: type,
      type_name: type_name,
      extendee: extendee
    }
  end

  # Google.Protobuf.FieldDescriptorProto.Label
  defp label_from_field_props(%Protobuf.FieldProps{optional?: true}),
    do: @field_label_mapping[:LABEL_OPTIONAL]

  defp label_from_field_props(%Protobuf.FieldProps{repeated?: true}),
    do: @field_label_mapping[:LABEL_REPEATED]

  defp label_from_field_props(%Protobuf.FieldProps{required?: true}),
    do: @field_label_mapping[:LABEL_REQUIRED]

  # Google.Protobuf.FieldDescriptorProto.Type
  defp type_from_field_props(%Protobuf.FieldProps{type: type}) do
    @field_type_mapping
    |> Map.get(:"TYPE_#{type |> Atom.to_string() |> String.upcase()}", type)
    |> then(fn type ->
      cond do
        is_integer(type) ->
          {type, nil}

        is_atom(type) and Code.ensure_loaded?(type) and function_exported?(type, :descriptor, 0) ->
          {@field_type_mapping[:TYPE_MESSAGE], get_pb_type_name(type)}

        true ->
          raise("Unsupported type")
      end
    end)
  end

  defp get_pb_type_name(type) do
    {packs, [name]} =
      type
      |> Module.split()
      |> Enum.split(-1)

    Enum.map_join(packs, ".", &downcase_first/1) <> "." <> name
  end

  def validate_services(services) do
    invalid_services =
      Enum.reject(services, fn service_mod ->
        is_binary(service_mod.__meta__(:name)) and
          is_struct(service_mod.descriptor())
      end)

    case invalid_services do
      [] -> :ok
      _ -> {:error, "non-service module provided"}
    end
  end

  def message_descriptor?(%Google.Protobuf.FieldDescriptorProto{type: @type_message}),
    do: true

  def message_descriptor?(_), do: false

  def get_syntax(module) do
    cond do
      Keyword.has_key?(module.__info__(:functions), :__message_props__) ->
        # this is a message type
        case module.__message_props__().syntax do
          :proto2 -> "proto2"
          :proto3 -> "proto3"
        end

      Keyword.has_key?(module.__info__(:functions), :__rpc_calls__) ->
        # this is a service definition, grab a message and recurse
        module.__rpc_calls__()
        |> Enum.find(fn
          {_, _, _} -> true
          {_, _, _, _} -> true
          _ -> false
        end)
        |> then(fn
          nil -> "proto2"
          {_, {req, _}, _} -> get_syntax(req)
          {_, {req, _}, _, _} -> get_syntax(req)
          {_, _, {req, _}} -> get_syntax(req)
          {_, _, {req, _}, _} -> get_syntax(req)
        end)

      true ->
        raise "Module #{inspect(module)} has neither rcp_calls nor __message_props__"
    end
  end

  def types_from_descriptor(%Google.Protobuf.ServiceDescriptorProto{} = descriptor) do
    descriptor.method
    |> Enum.flat_map(fn method -> [method.input_type, method.output_type] end)
    |> Enum.reject(&is_atom/1)
    |> Enum.map(&String.trim_leading(&1, "."))
  end

  def types_from_descriptor(%Google.Protobuf.DescriptorProto{} = descriptor) do
    (descriptor.field ++ Enum.flat_map(descriptor.nested_type, & &1.field))
    |> Enum.map(fn field -> field.type_name end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&String.trim_leading(&1, "."))
  end

  def types_from_descriptor(%Google.Protobuf.EnumDescriptorProto{}) do
    []
  end

  def trim_symbol("." <> symbol), do: symbol
  def trim_symbol(symbol), do: symbol
end
