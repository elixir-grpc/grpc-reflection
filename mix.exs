defmodule GrpcReflection.MixProject do
  use Mix.Project

  @version "0.4.0"
  @source_url "https://github.com/elixir-grpc/grpc-reflection"
  @description "gRPC reflection server for Elixir"

  def project do
    [
      app: :grpc_reflection,
      version: @version,
      description: @description,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      aliases: aliases(),
      test_coverage: [
        ignore_modules: [
          ~r/^Grpc\./,
          ~r/^Google\./,
          ~r/^ScalarTypes\./,
          ~r/^Streaming\./,
          ~r/^EmptyService\./,
          ~r/^EdgeCases\./,
          ~r/^Proto2Features\./,
          ~r/^CustomizedPrefix\./,
          ~r/^ImportsTest\./,
          ~r/^CommonTypes\./,
          ~r/^GlobalService$/,
          ~r/^GlobalRequest$/,
          ~r/^GlobalResponse$/,
          ~r/^Nested\./,
          ~r/^WellKnownTypes\./,
          ~r/^PackageA\./,
          ~r/^PackageB\./,
          ~r/^NestedEnumConflict\./,
          ~r/^RecursiveMessage\./,
          ~r/^NoDescriptor\./,
          GrpcReflection.TestEndpoint,
          GrpcReflection.TestEndpoint.Endpoint
        ]
      ],
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:grpc, "~> 0.11.1"},
      {:protobuf, "~> 0.15"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      build_protos: [&build_protos/1],
      check: ["dialyzer", "credo --strict"]
    ]
  end

  @protoc_opts "gen_descriptors=true,gen_proto_source=true,paths=source_relative,plugins=grpc"
  @protoc_opts_no_descriptor "package_prefix=NoDescriptor,gen_proto_source=true,paths=source_relative,plugins=grpc"
  # Protos that set (elixirpb.file).module_prefix must be skipped here: that option
  # overrides package_prefix entirely, so the no-descriptor pass would emit modules with
  # the same name as the descriptor pass, causing a compile-time conflict.
  # Add any proto that uses the elixirpb.file module_prefix option to this list.
  @skip_no_descriptor ["custom_prefix_service.proto"]

  defp build_protos(_argv) do
    {reflection, fixtures} =
      "./priv/protos/**/*.proto"
      |> Path.wildcard()
      |> Enum.split_with(&String.contains?(&1, "reflection.proto"))

    # compile reflection protos
    cmds =
      reflection
      |> Enum.map(fn reflection_proto ->
        # protoc now grabs the path to the file and includes it with
        # the message name, which for us leads to bad paths
        i_path =
          reflection_proto
          |> Path.split()
          |> List.delete_at(-1)
          |> Path.join()

        "protoc --elixir_out=#{@protoc_opts}:./lib/proto -I=#{i_path} #{reflection_proto}"
      end)

    # compile test protos — once with descriptors, once without
    fixtures
    |> Enum.flat_map(fn proto ->
      i_path =
        proto
        |> Path.split()
        |> List.delete_at(-1)
        |> Path.join()

      with_descriptors =
        "protoc --elixir_out=#{@protoc_opts}:./test/support/protos -I=#{i_path} -I priv/protos -I deps/protobuf/src #{proto}"

      without_descriptors =
        "protoc --elixir_out=#{@protoc_opts_no_descriptor}:./test/support/protos -I=#{i_path} -I priv/protos -I deps/protobuf/src #{proto}"

      if Enum.any?(@skip_no_descriptor, &String.contains?(proto, &1)) do
        [with_descriptors]
      else
        [with_descriptors, without_descriptors]
      end
    end)
    |> Enum.concat(cmds)
    |> Task.async_stream(&Mix.shell().cmd(&1))
    |> Enum.to_list()
  end

  defp package do
    %{
      name: "grpc_reflection",
      files: ~w(.formatter.exs mix.exs lib),
      links: %{"GitHub" => @source_url},
      licenses: ["Apache-2.0"]
    }
  end

  defp docs do
    [
      extras: [
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "#{@version}",
      formatters: ["html"]
    ]
  end

  defp dialyzer do
    [
      plt_local_path: "priv/plts/project",
      plt_core_path: "priv/plts/core",
      plt_add_apps: [:ex_unit],
      list_unused_filters: true
    ]
  end
end
