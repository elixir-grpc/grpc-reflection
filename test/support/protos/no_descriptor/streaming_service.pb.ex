defmodule NoDescriptor.Streaming.StreamRequest do
  @moduledoc false

  use Protobuf,
    full_name: "streaming.StreamRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :message, 1, type: :string
  field :sequence, 2, type: :int32
end

defmodule NoDescriptor.Streaming.StreamResponse do
  @moduledoc false

  use Protobuf,
    full_name: "streaming.StreamResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :result, 1, type: :string
  field :sequence, 2, type: :int32
  field :is_final, 3, type: :bool, json_name: "isFinal"
end

defmodule NoDescriptor.Streaming.DataChunk do
  @moduledoc false

  use Protobuf,
    full_name: "streaming.DataChunk",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :data, 1, type: :bytes
  field :offset, 2, type: :int64
  field :size, 3, type: :int32
end

defmodule NoDescriptor.Streaming.UploadStatus do
  @moduledoc false

  use Protobuf,
    full_name: "streaming.UploadStatus",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :success, 1, type: :bool
  field :total_bytes, 2, type: :int64, json_name: "totalBytes"
  field :checksum, 3, type: :string
end

defmodule NoDescriptor.Streaming.DownloadRequest do
  @moduledoc false

  use Protobuf,
    full_name: "streaming.DownloadRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :file_id, 1, type: :string, json_name: "fileId"
  field :start_offset, 2, type: :int64, json_name: "startOffset"
  field :max_bytes, 3, type: :int64, json_name: "maxBytes"
end

defmodule NoDescriptor.Streaming.StreamingService.Service do
  @moduledoc false

  use GRPC.Service, name: "streaming.StreamingService", protoc_gen_elixir_version: "0.16.0"

  rpc :UnaryCall, NoDescriptor.Streaming.StreamRequest, NoDescriptor.Streaming.StreamResponse

  rpc :ServerStreamingCall,
      NoDescriptor.Streaming.StreamRequest,
      stream(NoDescriptor.Streaming.StreamResponse)

  rpc :ClientStreamingCall,
      stream(NoDescriptor.Streaming.StreamRequest),
      NoDescriptor.Streaming.StreamResponse

  rpc :BidirectionalStreamingCall,
      stream(NoDescriptor.Streaming.StreamRequest),
      stream(NoDescriptor.Streaming.StreamResponse)
end

defmodule NoDescriptor.Streaming.StreamingService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.Streaming.StreamingService.Service
end

defmodule NoDescriptor.Streaming.MultiStreamService.Service do
  @moduledoc false

  use GRPC.Service, name: "streaming.MultiStreamService", protoc_gen_elixir_version: "0.16.0"

  rpc :UploadData, stream(NoDescriptor.Streaming.DataChunk), NoDescriptor.Streaming.UploadStatus

  rpc :DownloadData,
      NoDescriptor.Streaming.DownloadRequest,
      stream(NoDescriptor.Streaming.DataChunk)

  rpc :SyncData,
      stream(NoDescriptor.Streaming.DataChunk),
      stream(NoDescriptor.Streaming.DataChunk)
end

defmodule NoDescriptor.Streaming.MultiStreamService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.Streaming.MultiStreamService.Service
end
