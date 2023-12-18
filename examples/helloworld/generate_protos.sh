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

# protos for protobuf3
PROTOS=("
    priv/protos/helloworld.proto
")

# protos for protobuf2
PROTOS2=("
    priv/protos/helloworld_v2.proto
    priv/protos/helloworld_ext_v2.proto
")

for file in $PROTOS2; do
  protoc --elixir_out=plugins=grpc,gen_descriptors=true:./lib/protos --proto_path=priv/protos/ $file
done