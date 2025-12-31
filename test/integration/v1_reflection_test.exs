defmodule GrpcReflection.V1ReflectionTest do
  @moduledoc false

  use GrpcCase

  @moduletag capture_log: true

  @endpoint GrpcReflection.TestEndpoint.Endpoint
  setup_all do
    Protobuf.load_extensions()

    {:ok, _pid, port} = GRPC.Server.start_endpoint(@endpoint, 0)
    on_exit(fn -> :ok = GRPC.Server.stop_endpoint(@endpoint, []) end)
    start_supervised({GRPC.Client.Supervisor, []})

    host = "localhost:#{port}"
    {:ok, channel} = GRPC.Stub.connect(host)
    req = %Grpc.Reflection.V1.ServerReflectionRequest{host: host}

    %{channel: channel, req: req, stub: GrpcReflection.TestEndpoint.V1Server.Stub}
  end

  test "unsupported call is rejected", ctx do
    message = {:file_containing_extension, %Grpc.Reflection.V1.ExtensionRequest{}}
    assert {:error, _} = run_request(message, ctx)
  end

  test "listing services", ctx do
    message = {:list_services, ""}
    assert {:ok, %{service: service_list}} = run_request(message, ctx)
    names = Enum.map(service_list, &Map.get(&1, :name))

    assert names == [
             "helloworld.Greeter",
             "testserviceV2.TestService",
             "testserviceV3.TestService",
             "grpc.reflection.v1.ServerReflection",
             "grpc.reflection.v1alpha.ServerReflection"
           ]
  end

  describe "symbol queries" do
    test "ushould reject nknown symbol", ctx do
      message = {:file_containing_symbol, "other.Rejecter"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return a method on the service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter.SayHello"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return not found for an invalid method", ctx do
      # SayHellp is not a method on the service
      message = {:file_containing_symbol, "helloworld.Greeter.SayHellp"}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should resolve a type", ctx do
      message = {:file_containing_symbol, "helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end

    test "should return the containing file for a nested message", ctx do
      message = {:file_containing_symbol, "testserviceV3.TestRequest.Payload"}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == "testserviceV3.TestRequest.proto"
    end

    test "should resolve types with the leading period", ctx do
      message = {:file_containing_symbol, ".helloworld.HelloRequest"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)
    end
  end

  describe "filename queries" do
    test "should list methods on our service", ctx do
      message = {:file_containing_symbol, "helloworld.Greeter"}
      assert {:ok, response} = run_request(message, ctx)
      assert_response(response)

      # we pretend all modules are in different files, dependencies are listed
      assert response.dependency == [
               "helloworld.HelloRequest.proto",
               "helloworld.HelloReply.proto"
             ]
    end

    test "should reject an unrecognized filename", ctx do
      filename = "does.not.exist.proto"
      message = {:file_by_filename, filename}
      assert {:error, _} = run_request(message, ctx)
    end

    test "should resolve by filename", ctx do
      filename = "helloworld.HelloReply.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "helloworld"
      assert response.dependency == ["google.protobuf.Timestamp.proto"]

      assert [
               %Google.Protobuf.DescriptorProto{
                 name: "HelloReply",
                 field: [
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "message",
                     number: 1,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_STRING,
                     json_name: "message"
                   },
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "today",
                     number: 2,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_MESSAGE,
                     type_name: ".google.protobuf.Timestamp",
                     json_name: "today"
                   }
                 ]
               }
             ] = response.message_type
    end

    test "should resolve external dependency types", ctx do
      filename = "google.protobuf.Timestamp.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "google.protobuf"
      assert response.dependency == []

      assert [
               %Google.Protobuf.DescriptorProto{
                 field: [
                   %Google.Protobuf.FieldDescriptorProto{
                     json_name: "seconds",
                     label: :LABEL_OPTIONAL,
                     name: "seconds",
                     number: 1,
                     type: :TYPE_INT64
                   },
                   %Google.Protobuf.FieldDescriptorProto{
                     json_name: "nanos",
                     label: :LABEL_OPTIONAL,
                     name: "nanos",
                     number: 2,
                     type: :TYPE_INT32
                   }
                 ],
                 name: "Timestamp"
               }
             ] = response.message_type
    end

    test "should not duplicate dependencies in the file descriptor", ctx do
      filename = "testserviceV3.TestReply.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"

      assert response.dependency == [
               "google.protobuf.Timestamp.proto",
               "google.protobuf.StringValue.proto"
             ]
    end

    test "should exclude nested types from dependenciy list", ctx do
      filename = "testserviceV3.TestRequest.proto"
      message = {:file_by_filename, filename}
      assert {:ok, response} = run_request(message, ctx)
      assert response.name == filename
      assert response.package == "testserviceV3"

      assert response.dependency == [
               "testserviceV3.Enum.proto",
               "google.protobuf.Any.proto",
               "google.protobuf.StringValue.proto"
             ]
    end
  end

  describe "proto2 extensions" do
    test "should get all extension numbers by type", ctx do
      type = "testserviceV2.TestRequest"
      message = {:all_extension_numbers_of_type, type}
      assert {:ok, response} = run_request(message, ctx)
      assert response.base_type_name == type
      assert response.extension_number == [10, 11]
    end

    test "should get extension descriptor file by extendee", ctx do
      extendee = "testserviceV2.TestRequest"

      message =
        {:file_containing_extension,
         %Grpc.Reflection.V1.ExtensionRequest{containing_type: extendee, extension_number: 10}}

      assert {:ok, response} = run_request(message, ctx)
      assert response.name == extendee <> "Extension.proto"
      assert response.package == "testserviceV2"
      assert response.dependency == [extendee <> ".proto"]

      assert response.extension == [
               %Google.Protobuf.FieldDescriptorProto{
                 name: "data",
                 extendee: extendee,
                 number: 10,
                 label: :LABEL_OPTIONAL,
                 type: :TYPE_STRING,
                 type_name: nil
               },
               %Google.Protobuf.FieldDescriptorProto{
                 name: "location",
                 extendee: extendee,
                 number: 11,
                 label: :LABEL_OPTIONAL,
                 type: :TYPE_MESSAGE,
                 type_name: "testserviceV2.Location"
               }
             ]

      assert response.message_type == [
               %Google.Protobuf.DescriptorProto{
                 name: "Location",
                 field: [
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "latitude",
                     number: 1,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_DOUBLE,
                     json_name: "latitude"
                   },
                   %Google.Protobuf.FieldDescriptorProto{
                     name: "longitude",
                     extendee: nil,
                     number: 2,
                     label: :LABEL_OPTIONAL,
                     type: :TYPE_DOUBLE,
                     json_name: "longitude"
                   }
                 ]
               }
             ]
    end
  end

  test "reflection graph is traversable", ctx do
    ops =
      Stream.unfold([{:list_services, ""}], fn
        [] ->
          nil

        [{:list_services, ""} = message | rest] = term ->
          # add commands to get the files for the listed services
          {:ok, %{service: service_list}} = run_request(message, ctx)

          commands =
            Enum.map(service_list, fn %{name: service_name} ->
              {:file_containing_symbol, service_name}
            end)

          {term, commands ++ rest}

        [{:file_by_filename, _} = message | rest] = term ->
          message
          |> run_request(ctx)
          |> case do
            {:ok, descriptor} ->
              commands = links_from_descriptor(descriptor)
              {term, commands ++ rest}
          end

        [{:file_containing_extension, _} = message | rest] = term ->
          message
          |> run_request(ctx)
          |> case do
            {:ok, _descriptor} ->
              # extensions depend on the base type
              # if we load the dependencies and feed it into the unfold action
              # we get stuck in a loop
              {term, rest}

            {:error, %{error_message: "extension not found"}} ->
              {term, rest}
          end

        [{:file_containing_symbol, _} = message | rest] = term ->
          # get the file containing the symbol, and add commands to get the dependencies
          message
          |> run_request(ctx)
          |> case do
            {:ok, descriptor} ->
              commands = links_from_descriptor(descriptor)
              {term, commands ++ rest}
          end
      end)
      |> Enum.to_list()
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    assert ops == [
             {:file_by_filename, "google.protobuf.Any.proto"},
             {:file_by_filename, "google.protobuf.StringValue.proto"},
             {:file_by_filename, "google.protobuf.Timestamp.proto"},
             {:file_by_filename, "grpc.reflection.v1.ErrorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ExtensionNumberResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ExtensionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1.FileDescriptorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ListServiceResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ServerReflectionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1.ServerReflectionResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1.ServiceResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ErrorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ExtensionNumberResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ExtensionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.FileDescriptorResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ListServiceResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ServerReflectionRequest.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ServerReflectionResponse.proto"},
             {:file_by_filename, "grpc.reflection.v1alpha.ServiceResponse.proto"},
             {:file_by_filename, "helloworld.HelloReply.proto"},
             {:file_by_filename, "helloworld.HelloRequest.proto"},
             {:file_by_filename, "testserviceV2.Enum.proto"},
             {:file_by_filename, "testserviceV2.TestReply.proto"},
             {:file_by_filename, "testserviceV2.TestRequest.proto"},
             {:file_by_filename, "testserviceV3.Enum.proto"},
             {:file_by_filename, "testserviceV3.TestReply.proto"},
             {:file_by_filename, "testserviceV3.TestRequest.proto"},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 10,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 11,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 12,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 13,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 14,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 15,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 16,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 17,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 18,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 19,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 20,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest",
                extension_number: 21,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 10,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 11,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 12,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 13,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 14,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 15,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 16,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 17,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 18,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 19,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 20,
                __unknown_fields__: []
              }},
             {:file_containing_extension,
              %Grpc.Reflection.V1.ExtensionRequest{
                containing_type: "testserviceV2.TestRequest.GEntry",
                extension_number: 21,
                __unknown_fields__: []
              }},
             {:file_containing_symbol, ".grpc.reflection.v1.ServerReflectionRequest"},
             {:file_containing_symbol, ".grpc.reflection.v1.ServerReflectionResponse"},
             {:file_containing_symbol, ".grpc.reflection.v1alpha.ServerReflectionRequest"},
             {:file_containing_symbol, ".grpc.reflection.v1alpha.ServerReflectionResponse"},
             {:file_containing_symbol, ".helloworld.HelloReply"},
             {:file_containing_symbol, ".helloworld.HelloRequest"},
             {:file_containing_symbol, ".testserviceV2.TestReply"},
             {:file_containing_symbol, ".testserviceV2.TestRequest"},
             {:file_containing_symbol, ".testserviceV3.TestReply"},
             {:file_containing_symbol, ".testserviceV3.TestRequest"},
             {:file_containing_symbol, "grpc.reflection.v1.ServerReflection"},
             {:file_containing_symbol, "grpc.reflection.v1alpha.ServerReflection"},
             {:file_containing_symbol, "helloworld.Greeter"},
             {:file_containing_symbol, "testserviceV2.TestService"},
             {:file_containing_symbol, "testserviceV3.TestService"},
             {:list_services, ""}
           ]
  end

  defp links_from_descriptor(%Google.Protobuf.FileDescriptorProto{} = proto) do
    file_dependencies(proto) ++
      service_dependencies(proto) ++
      extension_dependencies(proto)
  end

  defp file_dependencies(%Google.Protobuf.FileDescriptorProto{dependency: dependencies}) do
    Enum.map(dependencies, fn dep_file ->
      {:file_by_filename, dep_file}
    end)
  end

  defp service_dependencies(%Google.Protobuf.FileDescriptorProto{service: services}) do
    Enum.flat_map(services, fn %{method: methods} ->
      Enum.flat_map(methods, fn
        %{input_type: input, output_type: output} ->
          [{:file_containing_symbol, input}, {:file_containing_symbol, output}]
      end)
    end)
  end

  defp extension_dependencies(%Google.Protobuf.FileDescriptorProto{
         package: package,
         message_type: types
       }) do
    gen_range = fn
      extendee, ranges ->
        ranges
        |> Enum.flat_map(fn %{start: start, end: finish} -> start..finish//1 end)
        |> Enum.map(fn num ->
          {:file_containing_extension,
           %Grpc.Reflection.V1.ExtensionRequest{
             containing_type: extendee,
             extension_number: num
           }}
        end)
    end

    Enum.flat_map(types, fn type ->
      extendee = package <> "." <> type.name
      extendee_commands = gen_range.(extendee, type.extension_range)

      nested_commands =
        Enum.flat_map(type.nested_type, fn nested_type ->
          extendee = extendee <> "." <> nested_type.name
          gen_range.(extendee, type.extension_range)
        end)

      extendee_commands ++ nested_commands
    end)
  end
end
