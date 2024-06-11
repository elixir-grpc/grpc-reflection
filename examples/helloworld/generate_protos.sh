#!/bin/bash

PROTOS=("
    priv/protos/helloworld.proto
")

for file in $PROTOS; do
  mix protobuf.generate \
    --output-path=./lib/protos \
    --include-docs=true \
    --generate-descriptors=true \
    --include-path=priv/protos/ \
    --include-path=./priv/protos/googleapis \
    --plugin=ProtobufGenerate.Plugins.GRPC \
    --one-file-per-module \
    $file
done
