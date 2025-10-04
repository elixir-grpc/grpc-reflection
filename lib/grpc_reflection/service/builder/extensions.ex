defmodule GrpcReflection.Service.Builder.Extensions do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.Builder.Acc
  alias GrpcReflection.Service.Builder.Util

  def add_extensions(%Acc{} = acc, symbol, module) do
    extension_file = symbol <> "Extension.proto"

    case process_extensions(module, symbol, extension_file, module.descriptor()) do
      {:ok, {extension_numbers, extension_payload}} ->
        extension_map = %{extension_file => %{file_descriptor_proto: [extension_payload]}}

        %{
          acc
          | extension_files: Map.merge(acc.extension_files, extension_map),
            extensions:
              Map.update(acc.extensions, symbol, extension_numbers, fn existing ->
                Enum.uniq(existing ++ extension_numbers)
              end)
        }

      :ignore ->
        acc
    end
  end

  defp process_extensions(
         mod,
         symbol,
         extension_file,
         %Google.Protobuf.DescriptorProto{extension_range: extension_range} = descriptor
       )
       when extension_range != [] do
    extensions =
      for %Google.Protobuf.DescriptorProto.ExtensionRange{
            start: start_index,
            end: end_index
          } <- descriptor.extension_range,
          index <- start_index..end_index,
          {_, ext} <- List.wrap(Protobuf.Extension.get_extension_props_by_tag(mod, index)) do
        {index, ext.field_props.type, Util.convert_to_field_descriptor(symbol, ext)}
      end

    message_list =
      for {_idx, type, ext} <- extensions, Util.message_descriptor?(ext) do
        type.descriptor()
      end

    unencoded_extension_payload = %Google.Protobuf.FileDescriptorProto{
      name: extension_file,
      package: Util.get_package(symbol),
      dependency: [Util.proto_filename(mod)],
      syntax: Util.get_syntax(mod),
      extension: Enum.map(extensions, fn {_, _, ext} -> ext end),
      message_type: message_list
    }

    {:ok,
     {Enum.map(extensions, fn {idx, _, _} -> idx end),
      FileDescriptorProto.encode(unencoded_extension_payload)}}
  end

  defp process_extensions(_, _, _, _), do: :ignore
end
