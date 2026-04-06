defmodule GrpcReflection.Service.Builder.Fallback do
#   @moduledoc """
#   Fallback descriptor generator for when the `descriptor()` function is missing.

#   This module extracts as much information as possible from gRPC-exposed metadata
#   (__meta__, __rpc_calls__, __message_props__) to generate FileDescriptorProtos.

#   This is used as a fallback when compiled descriptors are not available.
#   """

#   alias Google.Protobuf.DescriptorProto
#   alias Google.Protobuf.FieldDescriptorProto
#   alias Google.Protobuf.FileDescriptorProto
#   alias Google.Protobuf.ServiceDescriptorProto
#   alias Google.Protobuf.MethodDescriptorProto

#   @field_type_mapping FieldDescriptorProto.Type.mapping()
#   @field_label_mapping FieldDescriptorProto.Label.mapping()

#   @primitive_types [:string, :bytes, :bool]
#   @type_name_mapping %{
#     :int32 => "int32",
#     :int64 => "int64",
#     :uint32 => "uint32",
#     :uint64 => "uint64",
#     :sint32 => "int32",
#     :sint64 => "int64",
#     :float => "float",
#     :double => "double",
#     :bool => "bool",
#     :string => "string",
#     :bytes => "bytes"
#   }

#   @type_message Map.fetch!(@field_type_mapping, :TYPE_MESSAGE)

#   @doc """
#   Generate a service descriptor from gRPC-exposed metadata.

#   ## Requirements:
#   - Module must have `__meta__/0` function returning a meta struct
#   - Module must have `__rpc_calls__/0` function returning RPC call list

#   ## Returns:
#   {:ok, %ServiceDescriptorProto{...}} or {:error, reason}
#   """
#   def generate_service_descriptor(module) do
#     meta = module.__meta__()

#     case Keyword.get(meta, :name) do
#       nil ->
#         {:error, "Module #{inspect(module)} has no __meta__(:name)"}

#       service_name ->
#         # package = extract_package(service_name, meta)

#         methods =
#           module.__rpc_calls__()
#           |> Enum.map(&generate_method_descriptor/1)

#         {:ok,
#          %ServiceDescriptorProto{
#            name: service_name,
#            # package: package,
#            method: methods
#          }}
#     end
#   end

#   @doc """
#   Generate a message descriptor from gRPC-exposed metadata.

#   ## Requirements:
#   - Module must have `__meta__/0` function returning a meta struct
#   - Module must have `__message_props__/0` key in __info__(:functions)

#   ## Returns:
#   {:ok, %DescriptorProto{...}} or {:error, reason}
#   """
#   def generate_message_descriptor(module) do
#     meta = module.__meta__()

#     case Keyword.get(meta, :name) do
#       nil ->
#         {:error, "Module #{inspect(module)} has no __meta__(:name)"}

#       message_name ->
#         props = module.__message_props__()

#         fields =
#           props.field_props
#           |> Map.values()
#           |> Enum.map(&generate_field_descriptor/1)

#         {:ok,
#          %DescriptorProto{
#            name: message_name,
#            field: fields
#          }}
#     end
#   end

#   @doc """
#   Generate a FileDescriptorProto for any type of module.

#   Attempts to generate service descriptor first, then message descriptor as fallback.
#   """
  def generate_file_descriptor(module) do
    module
#     with {:ok, service_proto} <- try_generate_service_descriptor(module) do
#       # Service descriptor takes precedence
#       {:ok, %FileDescriptorProto{service: [service_proto]}}
#     else
#       _ ->
#         with {:ok, message_proto} <- try_generate_message_descriptor(module) do
#           # Message descriptor as fallback
#           {:ok, %FileDescriptorProto{message_type: [message_proto]}}
#         else
#           {:error, _} ->
#             # No metadata available - can't generate anything
#             nil
#         end
#     end
  end

#   defp try_generate_service_descriptor(module) do
#     meta = module.__meta__()

#     cond do
#       not Keyword.has_key?(meta, :name) -> {:error, "No service name found"}

#       Keyword.has_key?(meta, :name) and
#              Keyword.has_key?(module.__info__(:functions), :__rpc_calls__) ->
#              # Has service name AND rpc calls - this is a service module
#              {:ok,
#               %ServiceDescriptorProto{
#                 name: Keyword.get(meta, :name),
#                 # package: extract_package(Keyword.get(meta, :name)),
#                 method: module.__rpc_calls__() |> Enum.map(&generate_method_descriptor/1)
#               }}

#       true ->
#         {:error, "Module has service name but no __rpc_calls__"}
#     end
#   end

#   defp try_generate_message_descriptor(module) do
#     meta = module.__meta__()

#     cond do
#       not Keyword.has_key?(meta, :name) -> {:error, "No message name found"}

#       Keyword.has_key?(meta, :name) and
#              Keyword.has_key?(module.__info__(:functions), :__message_props__) ->
#              props = module.__message_props__()

#              fields =
#                props.field_props
#                |> Map.values()
#                |> Enum.map(&generate_field_descriptor/1)

#              {:ok,
#               %DescriptorProto{
#                 name: Keyword.get(meta, :name),
#                 field: fields
#               }}

#       true ->
#         {:error, "Module has message name but no __message_props__"}
#     end
#   end

#   @doc """
#   Generate a method descriptor from an RPC call tuple.

#   ## Input:
#   {:method_name, {request_type, response_type}, client_streaming?, server_streaming?}

#   ## Returns:
#   %MethodDescriptorProto{...}
#   """
#   def generate_method_descriptor(
#         {method_name, {request_type, response_type}, client_streaming?, server_streaming?}
#       ) do
#     %MethodDescriptorProto{
#       name: method_name,
#       client_streaming: client_streaming?,
#       server_streaming: server_streaming?,
#       input_type: resolve_type_name(request_type),
#       output_type: resolve_type_name(response_type)
#     }
#   end

#   @doc """
#   Generate a field descriptor from a FieldProps struct.

#   ## Returns:
#   %FieldDescriptorProto{...} with approximated type_name
#   """
#   def generate_field_descriptor(%Protobuf.FieldProps{
#         name: name,
#         # number: number,
#         type: prop_type,
#         # Required for proto2 compatibility
#         label: _label = nil
#       }) do
#     field_type =
#       if(is_atom(prop_type),
#         do: :"TYPE_#{prop_type |> Atom.to_string() |> String.upcase()}",
#         else: prop_type
#       )

#     type_name = resolve_type_name(prop_type, field_type)

#     %FieldDescriptorProto{
#       name: name,
#       number: number,
#       # Default to optional for proto2 compatibility
#       label: @field_label_mapping[:LABEL_OPTIONAL],
#       type: field_type,
#       type_name: type_name
#     }
#   end

#   def generate_field_descriptor(%Protobuf.FieldProps{
#         name: name,
#         number: number,
#         type: prop_type,
#         # Required for proto2 compatibility
#         required?: true
#       }) do
#     field_type =
#       if(is_atom(prop_type),
#         do: :"TYPE_#{prop_type |> Atom.to_string() |> String.upcase()}",
#         else: prop_type
#       )

#     type_name = resolve_type_name(prop_type, field_type)

#     %FieldDescriptorProto{
#       name: name,
#       number: number,
#       label: @field_label_mapping[:LABEL_REQUIRED],
#       type: field_type,
#       type_name: type_name
#     }
#   end

#   def generate_field_descriptor(%Protobuf.FieldProps{
#         name: name,
#         number: number,
#         # Repeated for proto3 compatibility
#         repeated?: true
#       }) do
#     field_type =
#       if(is_atom(prop_type),
#         do: :"TYPE_#{prop_type |> Atom.to_string() |> String.upcase()}",
#         else: prop_type
#       )

#     type_name = resolve_type_name(prop_type, field_type)

#     %FieldDescriptorProto{
#       name: name,
#       number: number,
#       label: @field_label_mapping[:LABEL_REPEATED],
#       type: field_type,
#       type_name: type_name
#     }
#   end

#   @doc """
#   Resolve type name for a field type.

#   ## Returns:
#   - nil for primitive types (string, bytes, bool)
#   - "module.TypeName" for message types (approximated)
#   """
#   def resolve_type_name(type, field_type \\ nil) do
#     cond do
#       type in @primitive_types ->
#         nil

#       is_atom(type) and function_exported?(type, :descriptor, 0) ->
#         # Type has its own descriptor - it's a message type
#         generate_type_name(type)

#       true ->
#         # Unknown or primitive - use nil
#         nil
#     end
#   end

#   @doc """
#   Generate a fully qualified type name from a module.

#   ## Returns:
#   "module.TypeName" format (lowercase, dot-separated)

#   ## Note:
#   This is an approximation. The actual FQDN might be different if the type
#   comes from a different module or is defined in a nested scope.
#   """
#   def generate_type_name(type) do
#     {packs, [name]} =
#       type
#       |> Module.split()
#       |> Enum.split(-1)

#     Enum.map_join(packs, ".", &downcase_first/1) <> "." <> name
#   end

#   @doc """
#   Extract package name from a service symbol by removing nested type components.

#   ## Example:
#   "helloworld.Greeter" -> "helloworld"
#   "com.example.v1.User.Service" -> "com.example.v1"

#   ## Note:
#   Nested types start with uppercase letters. We remove everything after the last
#   lowercase segment to get the package name.
#   """
#   def extract_package(service_name, meta) do
#     # First try to get package from meta
#     case Keyword.get(meta, :package) do
#       nil ->
#         # Fallback: extract from service name
#         extract_from_name(service_name)

#       package ->
#         # Prefer the explicit package from meta
#         package
#     end
#   end

#   defp extract_from_name(service_name) do
#     service_name
#     |> String.split(".")
#     |> Enum.reject(fn s -> Regex.match?(~r/^[A-Z]/, s) end)
#     |> Enum.reject(&is_nil/1)
#     |> Enum.join(".")
#   end

#   @doc """
#   Convert first character to lowercase for protobuf naming convention.

#   ## Example:
#   "MyType" -> "mytype"
#   "com.Example" -> "com.example"
#   """
#   def downcase_first(<<first::utf8, rest::binary>>),
#     do: String.downcase(<<first::utf8>>) <> rest

#   def downcase_first(char) when is_binary(char),
#     do: char

#   @doc """
#   Determine if a field is optional based on the Prop struct.

#   ## Returns:
#   true or false
#   """
#   def optional?(%Protobuf.FieldProps{optional?: opt}) do
#     # Default to false if not specified (proto3 default)
#     opt || false
#   end

#   @doc """
#   Determine if a field is repeated based on the Prop struct.

#   ## Returns:
#   true or false
#   """
#   def repeated?(%Protobuf.FieldProps{repeated?: rep}) do
#     # Default to false if not specified (proto3 default)
#     rep || false
#   end

#   @doc """
#   Determine if a field is required based on the Prop struct.

#   ## Returns:
#   true or false
#   """
#   def required?(%Protobuf.FieldProps{required?: req}) do
#     # Default to false (proto3 doesn't have required)
#     req || false
#   end

#   @doc """
#   Determine if a method is client streaming based on the RPC call tuple.

#   ## Input:
#   {:method_name, {request_type, response_type}, client_streaming?, server_streaming?}

#   ## Returns:
#   true or false (defaults to false)
#   """
#   def client_streaming({_, _, streaming?}) do
#     streaming? || false
#   end

#   @doc """
#   Determine if a method is server streaming based on the RPC call tuple.

#   ## Input:
#   {:method_name, {request_type, response_type}, client_streaming?, server_streaming?}

#   ## Returns:
#   true or false (defaults to false)
#   """
#   def server_streaming({_, _, _, streaming?}) do
#     streaming? || false
#   end

#   @doc """
#   Check if a type is a message type (not primitive).

#     ## Returns:
#   true if the type has a descriptor, false otherwise
#   """
#   def message_type?(type) do
#     is_atom(type) and function_exported?(type, :descriptor, 0)
#   end

#   @doc """
#   Check if a type is a primitive type.

#   ## Returns:
#   true if the type is in the list of known primitive types
#   """
#   def primitive_type?(type) do
#     type in @primitive_types
#   end

#   @doc """
#   Get the protobuf label constant for a field based on its property.

#   ## Returns:
#   The appropriate LABEL_* constant from FieldDescriptorProto.Label
#   """
#   def label_from_prop(%Protobuf.FieldProps{optional?: true}),
#     do: @field_label_mapping[:LABEL_OPTIONAL]

#   def label_from_prop(%Protobuf.FieldProps{repeated?: true}),
#     do: @field_label_mapping[:LABEL_REPEATED]

#   def label_from_prop(%Protobuf.FieldProps{required?: true}),
#     do: @field_label_mapping[:LABEL_REQUIRED]

#   def label_from_prop(_),
#     # Default to optional
#     # Default to optional
#     # Default to optional
#     # Default to optional
#     do: @field_label_mapping[:LABEL_OPTIONAL]
end
