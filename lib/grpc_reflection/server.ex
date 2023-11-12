defmodule GrpcReflection.Server do
  @moduledoc """
  A grpc reflection server supports a specific iteration of the reflection protocol

  All versions currently "support" file descriptors by having an encoded proto2 payload as an array of bytes

  ### v1alpha
  The originally proposed specification.  This was around long enough that it has some application support

  ### v1
  The current spec for reflection support within GRPC.
  """
end
