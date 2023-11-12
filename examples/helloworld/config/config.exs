import Config

config :grpc_reflection, services: [Helloworld.Greeter.Service]

import_config "#{Mix.env()}.exs"
