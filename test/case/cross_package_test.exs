defmodule GrpcReflection.Case.CrossPackageTest do
  @moduledoc false

  use GrpcCase, service: PackageB.ServiceB.Service

  versions = ["v1", "v1alpha"]

  for version <- versions do
    describe version do
      setup String.to_existing_atom("stub_#{version}_server")

      test "should list services", ctx do
        message = {:list_services, ""}
        assert {:ok, %{service: service_list}} = run_request(message, ctx)
        assert Enum.map(service_list, &Map.get(&1, :name)) == ["package_b.ServiceB"]
      end

      test "should list methods on our service", ctx do
        message = {:file_containing_symbol, "package_b.ServiceB"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "package_b",
                 service: [
                   %Google.Protobuf.ServiceDescriptorProto{
                     name: "ServiceB",
                     method: [
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "ProcessB",
                         input_type: ".package_b.MessageB",
                         output_type: ".package_b.ResponseB"
                       },
                       %Google.Protobuf.MethodDescriptorProto{
                         name: "ProcessA",
                         input_type: ".package_a.MessageA",
                         output_type: ".package_a.MessageA"
                       }
                     ]
                   }
                 ]
               } = response
      end

      test "cross-package type is resolvable by symbol", ctx do
        message = {:file_containing_symbol, "package_a.MessageA"}
        assert {:ok, response} = run_request(message, ctx)

        assert %Google.Protobuf.FileDescriptorProto{
                 package: "package_a",
                 message_type: [%Google.Protobuf.DescriptorProto{name: "MessageA"}]
               } = response
      end

      test "reflection graph is traversable using grpcurl", ctx do
        ops = GrpcReflection.TestClient.grpcurl_service(ctx)

        assert {:call, "package_b.ServiceB.ProcessB"} in ops
        assert {:call, "package_b.ServiceB.ProcessA"} in ops
        assert {:service, "package_b.ServiceB"} in ops
      end
    end
  end
end
