#!/bin/bash

rm -rf ./lib/protos
mkdir ./lib/protos

GOOGLE_PROTOS=("
    protobuf/src/google/protobuf/any.proto
    protobuf/src/google/protobuf/duration.proto
    protobuf/src/google/protobuf/empty.proto
    protobuf/src/google/protobuf/field_mask.proto
    protobuf/src/google/protobuf/struct.proto
    protobuf/src/google/protobuf/timestamp.proto
    protobuf/src/google/protobuf/wrappers.proto
")

for file in $GOOGLE_PROTOS; do
  protoc --elixir_out=plugins=grpc,gen_descriptors=true:./lib/protos --proto_path=protobuf/src/ $file
done

PROTOS=("
    priv/protos/helloworld.proto
")

for file in $PROTOS; do
  protoc --elixir_out=plugins=grpc,gen_descriptors=true:./lib/protos --proto_path=priv/protos/ $file
done