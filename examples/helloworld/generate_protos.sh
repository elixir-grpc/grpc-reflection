#!/bin/bash

rm -rf ./lib/protos
mkdir ./lib/protos

PROTOS=("
    priv/protos/helloworld.proto
")

for file in $PROTOS; do
  protoc --elixir_opt=include_docs=true --elixir_out=plugins=grpc,gen_descriptors=true:./lib/protos --proto_path=priv/protos/ $file
done
