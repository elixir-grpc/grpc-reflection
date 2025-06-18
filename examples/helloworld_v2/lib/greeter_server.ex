defmodule Helloworld.Greeter.Server do
  use GRPC.Server, service: HLW.Greeter.Service

  @spec say_hello(Helloworld.HelloRequest.t(), GRPC.Server.Stream.t()) ::
          HLW.HelloReply.t()
  def say_hello(request, _stream) do
    nanos_epoch = System.system_time() |> System.convert_time_unit(:native, :nanosecond)
    seconds = div(nanos_epoch, 1_000_000_000)
    nanos = nanos_epoch - seconds * 1_000_000_000

    %HLW.HelloReply{
      message: "Hello #{request.name}",
      today: %Google.Protobuf.Timestamp{seconds: seconds, nanos: nanos}
    }
  end
end
