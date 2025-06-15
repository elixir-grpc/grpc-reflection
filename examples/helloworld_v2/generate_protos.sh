#!/bin/bash

protoc \
  -I deps/protobuf/src \
  -I priv/protos \
  --elixir_opt=include_docs=true \
  --elixir_out=plugins=grpc,gen_descriptors=true:lib/protos \
  priv/protos/*.proto
