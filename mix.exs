defmodule GrpcReflection.MixProject do
  use Mix.Project

  @version "0.3.3"
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

  @protoc_opts "gen_descriptors=true,plugins=grpc"
  @protoc_opts_no_descriptor "package_prefix=NoDescriptor,plugins=grpc"
  # Protos with a file-level (elixirpb.file).module_prefix override package_prefix,
  # so the no-descriptor pass would produce duplicate module names.
  @skip_no_descriptor ["custom_prefix_service.proto"]

  defp build_protos(_argv) do
    # compile reflection protos
    Enum.each(
      [
        "priv/protos/grpc/reflection/v1alpha/reflection.proto",
        "priv/protos/grpc/reflection/v1/reflection.proto"
      ],
      fn reflection_proto ->
        Mix.shell().cmd(
          "protoc --elixir_out=#{@protoc_opts}:./lib/proto --proto_path=priv/protos/ #{reflection_proto}"
        )
      end
    )

    # compile test protos — once with descriptors, once without
    "./priv/protos"
    |> File.ls!()
    |> Enum.filter(&Regex.match?(~r/.*.proto$/, &1))
    |> Enum.each(fn proto ->
      Mix.shell().cmd(
        "protoc --elixir_out=#{@protoc_opts}:./test/support/protos -I priv/protos/ -I deps/protobuf/src #{proto}"
      )

      unless proto in @skip_no_descriptor do
        Mix.shell().cmd(
          "protoc --elixir_out=#{@protoc_opts_no_descriptor}:./test/support/protos/no_descriptor -I priv/protos/ -I deps/protobuf/src #{proto}"
        )
      end
    end)
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
