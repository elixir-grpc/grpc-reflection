defmodule GrpcReflection.Service.Builder.Util do
  @moduledoc """
  Utility functions for the builder.
  """
  @field_type_mapping Google.Protobuf.FieldDescriptorProto.Type.mapping()
  @field_label_mapping Google.Protobuf.FieldDescriptorProto.Label.mapping()

  def package_from_name(service_name) do
    service_name
    |> String.split(".")
    |> Enum.reverse()
    |> then(fn [_ | rest] -> rest end)
    |> Enum.reverse()
    |> Enum.join(".")
  end

  def upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

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
end
