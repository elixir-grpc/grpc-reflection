defmodule GrpcReflection.Service.Util do
  @moduledoc false

  def upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

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
  defp label_from_field_props(%Protobuf.FieldProps{optional?: true}), do: 1
  defp label_from_field_props(%Protobuf.FieldProps{repeated?: true}), do: 3
  defp label_from_field_props(%Protobuf.FieldProps{required?: true}), do: 2

  # Google.Protobuf.FieldDescriptorProto.Type
  def type_from_field_props(%Protobuf.FieldProps{type: :double}), do: {1, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :float}), do: {2, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :int64}), do: {3, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :uint64}), do: {4, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :int32}), do: {5, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :fixed64}), do: {6, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :fixed32}), do: {7, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :bool}), do: {8, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :string}), do: {9, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :group}), do: {10, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :bytes}), do: {12, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :uint32}), do: {13, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :enum}), do: {14, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :sfixed32}), do: {15, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :sfixed64}), do: {16, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :sint32}), do: {17, nil}
  def type_from_field_props(%Protobuf.FieldProps{type: :sint64}), do: {18, nil}

  def type_from_field_props(%Protobuf.FieldProps{type: type}) do
    if is_atom(type) and Code.ensure_loaded?(type) and function_exported?(type, :descriptor, 0) do
      {11, get_pb_type_name(type)}
    else
      raise("Unsupported type")
    end
  end

  defp get_pb_type_name(type) do
    {packs, [name]} =
      type
      |> Module.split()
      |> Enum.split(-1)

    (Enum.map(packs, &String.downcase/1) |> Enum.join(".")) <> "." <> name
  end
end
