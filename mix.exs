defmodule GrpcReflection.MixProject do
  use Mix.Project

  def project do
    [
      app: :grpc_reflection,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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
      {:grpc, path: "../grpc"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      build_protos: [&build_protos/1]
    ]
  end

  defp build_protos(_argv) do
    options =
      Enum.join(
        [
          "gen_descriptors=true",
          "plugins=grpc",
          "include_docs=true"
        ],
        ","
      )

    reflection_proto = "priv/protos/grpc/reflection/v1/reflection.proto"

    Mix.shell().cmd(
      "protoc --elixir_out=#{options}:./lib --proto_path=priv/protos/ #{reflection_proto}"
    )
  end
end
