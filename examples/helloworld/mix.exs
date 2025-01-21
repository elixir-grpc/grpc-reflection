defmodule Helloworld.Mixfile do
  use Mix.Project

  def project do
    [
      app: :helloworld,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [mod: {HelloworldApp, []}, applications: [:logger, :grpc, :grpc_reflection]]
  end

  defp deps do
    [
      {:grpc, "~> 0.9"},
      {:grpc_reflection, path: "../.."},
      {:protobuf, github: "elixir-protobuf/protobuf", ref: "cbb4c919b925f509696c6e58ca2e181b767f7f1f", override: true},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false}
    ]
  end
end
