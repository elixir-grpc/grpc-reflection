[
  inputs:
    [
      "{mix,.formatter,.credo}.exs",
      "{config,lib,priv,test}/**/*.{ex,exs}",
      "examples/helloworld_v2/{config,lib,priv,test}/**/*.{ex,exs}",
      "examples/helloworld_v3/{config,lib,priv,test}/**/*.{ex,exs}"
    ]
    |> Enum.flat_map(&Path.wildcard(&1, match_dot: true))
    |> Enum.reject(&String.match?(&1, ~r/^.*\.pb\.ex$/))
]
