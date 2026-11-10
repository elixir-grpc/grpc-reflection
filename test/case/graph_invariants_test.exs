defmodule GrpcReflection.Case.GraphInvariantsTest do
  @moduledoc """
  Builds the reflection tree for every fixture service and link-checks it the way a
  reflection client would: dependencies exist, there are no cycles (including a file
  depending on itself), every type name resolves through the file or its direct
  dependencies, and every indexed symbol is defined by the file it points to.
  """

  use ExUnit.Case, async: true

  alias GrpcReflection.GraphCheck
  alias GrpcReflection.Service.Builder

  @descriptor_services [
    CustomizedPrefix.PrefixService.Service,
    EdgeCases.EdgeCaseService.Service,
    EmptyService.EmptyService.Service,
    GlobalService.Service,
    ImportsTest.ImportTestService.Service,
    Nested.NestedService.Service,
    NestedEnumConflict.ConflictService.Service,
    NestedCrossReference.Service.Service,
    NestedCycle.Service.Service,
    NestedDeepDependency.Service.Service,
    NestedSelfReference.Service.Service,
    PackageB.ServiceB.Service,
    Proto2Features.Proto2Service.Service,
    RecursiveMessage.Service.Service,
    ScalarTypes.ScalarService.Service,
    ShortNames.Service.Service,
    SelfReference.Service.Service,
    Streaming.MultiStreamService.Service,
    Streaming.StreamingService.Service,
    WellKnownTypes.WellKnownTypesService.Service
  ]

  @no_descriptor_services [
    NoDescriptor.DeprecatedFields.DeprecatedFieldsService.Service,
    NoDescriptor.EdgeCases.EdgeCaseService.Service,
    NoDescriptor.ImportsTest.ImportTestService.Service,
    NoDescriptor.Nested.NestedService.Service,
    NoDescriptor.NestedCrossReference.Service.Service,
    NoDescriptor.NestedCycle.Service.Service,
    NoDescriptor.NestedDeepDependency.Service.Service,
    NoDescriptor.NestedSelfReference.Service.Service,
    NoDescriptor.Proto2Features.Proto2Service.Service,
    NoDescriptor.RecursiveMessage.Service.Service,
    NoDescriptor.ScalarTypes.ScalarService.Service,
    NoDescriptor.ShortNames.Service.Service,
    NoDescriptor.SelfReference.Service.Service,
    NoDescriptor.Streaming.StreamingService.Service,
    NoDescriptor.WellKnownTypes.WellKnownTypesService.Service
  ]

  for service <- @descriptor_services ++ @no_descriptor_services do
    test "#{inspect(service)} builds a sound reflection graph" do
      assert {:ok, state} = Builder.build_reflection_tree([unquote(service)])
      assert GraphCheck.violations(state) == []
    end
  end
end
