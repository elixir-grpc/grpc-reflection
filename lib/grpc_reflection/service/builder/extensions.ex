defmodule GrpcReflection.Service.Builder.Extensions do
  @moduledoc false

  alias Google.Protobuf.FileDescriptorProto
  alias GrpcReflection.Service.Builder.Util
  alias GrpcReflection.Service.State

  def add_extensions(state, symbol, module) do
    extension_file = symbol <> "Extension.proto"

    case process_extensions(module, symbol, extension_file, module.descriptor()) do
      {:ok, {extension_numbers, extension_payload}} ->
        state
        |> State.add_files(
          Map.put(%{}, extension_file, %{file_descriptor_proto: [extension_payload]})
        )
        |> State.add_extensions(%{symbol => extension_numbers})

      {:ignore, _} ->
        state
    end
  end

  defp process_extensions(
         mod,
         symbol,
         extension_file,
         %Google.Protobuf.DescriptorProto{extension_range: extension_range} = descriptor
       )
       when extension_range != [] do
    unencoded_extension_payload = %Google.Protobuf.FileDescriptorProto{
      name: extension_file,
      package: Util.get_package(symbol),
      dependency: [symbol <> ".proto"],
      syntax: Util.get_syntax(mod)
    }

    {extension_numbers, extension_files} =
      Enum.unzip(
        for %Google.Protobuf.DescriptorProto.ExtensionRange{
              start: start_index,
              end: end_index
            } <- descriptor.extension_range,
            index <- start_index..end_index,
            {_, ext} <- List.wrap(Protobuf.Extension.get_extension_props_by_tag(mod, index)) do
          {index, Util.convert_to_field_descriptor(symbol, ext)}
        end
      )

    message_list =
      for ext <- extension_files, Util.message_descriptor?(ext) do
        ext.type_name
        |> Util.convert_symbol_to_module!()
        |> then(& &1.descriptor())
      end

    unencoded_extension_payload = %{
      unencoded_extension_payload
      | extension: extension_files,
        message_type: message_list
    }

    {:ok, {extension_numbers, FileDescriptorProto.encode(unencoded_extension_payload)}}
  end

  defp process_extensions(_, _, _, _), do: {:ignore, {nil, nil}}
end
