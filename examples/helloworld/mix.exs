defmodule Helloworld.Mixfile do
  use Mix.Project

  def project do
    [
      app: :helloworld,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [mod: {HelloworldApp, []}, applications: [:logger, :grpc]]
  end

  defp deps do
    [
      {:grpc, path: "../../grpc"},
      {:grpc_reflection, path: "../.."},
      {:protobuf, "~> 0.11"},
      {:google_protos, "~> 0.3.0"},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false}
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
