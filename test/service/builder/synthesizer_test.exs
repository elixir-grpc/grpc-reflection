defmodule GrpcReflection.Service.Builder.SynthesizerTest do
  use ExUnit.Case, async: true

  alias GrpcReflection.Service.Builder.Synthesizer

  # Fields that reflection clients care about. We exclude:
  # - proto3_optional: proto2 real descriptors use nil, synthesizer uses false — both falsy
  # - __unknown_fields__: internal protobuf bookkeeping
  @comparable_field_keys [
    :name,
    :number,
    :type,
    :label,
    :type_name,
    :default_value,
    :oneof_index,
    :options,
    :json_name,
    :extendee
  ]

  defp comparable_field(f) do
    f
    |> Map.take(@comparable_field_keys)
    |> Map.update(:options, nil, &normalize_options/1)
  end

  # The real descriptor populates many FieldOptions fields with defaults (ctype, deprecated,
  # lazy, etc). We only synthesize packed, so normalize to just that for comparison.
  defp normalize_options(nil), do: nil
  defp normalize_options(%Google.Protobuf.FieldOptions{packed: packed}), do: %{packed: packed}

  defp comparable_fields(descriptor), do: Enum.map(descriptor.field, &comparable_field/1)

  describe "field_descriptor_from_props/1" do
    test "proto3_optional field has proto3_optional true but no oneof_index at this level" do
      # oneof_index for proto3_optional is assigned in message_descriptor/1, not here,
      # because the synthetic index depends on how many real oneofs precede it.
      props = NoDescriptor.ScalarTypes.ScalarRequest.__message_props__().field_props[18]

      assert %Google.Protobuf.FieldDescriptorProto{
               name: "optional_string",
               proto3_optional: true,
               oneof_index: nil
             } = Synthesizer.field_descriptor_from_props(props)
    end
  end

  describe "message_descriptor/1 matches real descriptor" do
    test "Proto2Request fields match protoc output" do
      real = Proto2Features.Proto2Request.descriptor()
      synth = Synthesizer.message_descriptor(NoDescriptor.Proto2Features.Proto2Request)

      assert synth.name == real.name
      assert synth.oneof_decl == real.oneof_decl
      assert synth.extension_range == real.extension_range
      assert comparable_fields(synth) == comparable_fields(real)
    end

    test "ScalarRequest fields match protoc output" do
      real = ScalarTypes.ScalarRequest.descriptor()
      synth = Synthesizer.message_descriptor(NoDescriptor.ScalarTypes.ScalarRequest)

      assert synth.name == real.name
      assert comparable_fields(synth) == comparable_fields(real)
    end

    test "ScalarReply fields match protoc output" do
      real = ScalarTypes.ScalarReply.descriptor()
      synth = Synthesizer.message_descriptor(NoDescriptor.ScalarTypes.ScalarReply)

      assert synth.name == real.name
      assert comparable_fields(synth) == comparable_fields(real)
    end

    test "proto3_optional fields get synthetic oneof_index and oneof_decl" do
      real = ScalarTypes.ScalarRequest.descriptor()
      synth = Synthesizer.message_descriptor(NoDescriptor.ScalarTypes.ScalarRequest)

      real_by_name = Map.new(real.field, &{&1.name, &1})
      synth_by_name = Map.new(synth.field, &{&1.name, &1})

      assert real_by_name["optional_string"].oneof_index ==
               synth_by_name["optional_string"].oneof_index

      assert real_by_name["optional_int"].oneof_index ==
               synth_by_name["optional_int"].oneof_index

      real_decl_names = Enum.map(real.oneof_decl, & &1.name)
      synth_decl_names = Enum.map(synth.oneof_decl, & &1.name)
      assert real_decl_names == synth_decl_names
    end
  end

  describe "enum_descriptor/1 matches real descriptor" do
    test "Status matches protoc output" do
      real = Proto2Features.Status.descriptor()
      synth = Synthesizer.enum_descriptor(NoDescriptor.Proto2Features.Status)

      assert synth == real
    end

    test "DetailedStatus values and names match protoc output" do
      real = EdgeCases.DetailedStatus.descriptor()
      synth = Synthesizer.enum_descriptor(NoDescriptor.EdgeCases.DetailedStatus)

      assert synth.name == real.name

      # Values are sorted by number (runtime limitation — declaration order is not
      # available without descriptor/0). Clients look up by number so this is safe.
      real_by_number = Map.new(real.value, &{&1.number, &1.name})
      synth_by_number = Map.new(synth.value, &{&1.number, &1.name})
      assert synth_by_number == real_by_number

      # Ordering is numeric, including negative values and max int32
      assert Enum.map(synth.value, & &1.number) == Enum.sort(Enum.map(real.value, & &1.number))
    end
  end

  describe "service_descriptor/1 matches real descriptor" do
    test "Proto2Service matches protoc output" do
      real = Synthesizer.service_descriptor(Proto2Features.Proto2Service.Service)
      synth = Synthesizer.service_descriptor(NoDescriptor.Proto2Features.Proto2Service.Service)

      assert synth == real
    end

    test "StreamingService matches protoc output" do
      real = Synthesizer.service_descriptor(Streaming.StreamingService.Service)
      synth = Synthesizer.service_descriptor(NoDescriptor.Streaming.StreamingService.Service)

      assert synth == real
    end
  end
end
