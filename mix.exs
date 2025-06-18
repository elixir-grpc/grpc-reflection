defmodule GrpcReflection.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/elixir-grpc/grpc-reflection"
  @description "gRPC reflection server for Elixir"

  def project do
    [
      app: :grpc_reflection,
      version: @version,
      description: @description,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      aliases: aliases(),
      test_coverage: [
        ignore_modules: [
          ~r/^Grpc\./,
          ~r/^Helloworld\./,
          ~r/^TestserviceV2\./,
          ~r/^TestserviceV3\./,
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
      {:grpc, "~> 0.10"},
      {:protobuf, "~> 0.14"}
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

  defp build_protos(_argv) do
    options =
      Enum.join(
        [
          "gen_descriptors=true",
          "plugins=grpc"
        ],
        ","
      )

    # compile reflection protos
    Enum.each(
      [
        "priv/protos/grpc/reflection/v1alpha/reflection.proto",
        "priv/protos/grpc/reflection/v1/reflection.proto"
      ],
      fn reflection_proto ->
        Mix.shell().cmd(
          "protoc --elixir_out=#{options}:./lib/proto --proto_path=priv/protos/ #{reflection_proto}"
        )
      end
    )

    # compile test protos
    "./priv/protos"
    |> File.ls!()
    |> Enum.filter(&Regex.match?(~r/.*.proto$/, &1))
    |> Enum.each(fn reflection_proto ->
      Mix.shell().cmd(
        "protoc --elixir_out=#{options}:./test/support/protos -I priv/protos/ -I deps/protobuf/src #{reflection_proto}"
      )
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
