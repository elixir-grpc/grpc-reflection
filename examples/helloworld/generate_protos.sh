#!/bin/bash

protoc -I priv/protos \
  --elixir_out=plugins=grpc:./lib/protos \
  --elixir_opt=include_docs=true \
  --elixir_out=plugins=grpc,gen_descriptors=true:lib/protos \
  priv/protos/*.proto