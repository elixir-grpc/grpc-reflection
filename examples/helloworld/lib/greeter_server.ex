defmodule Helloworld.Greeter.Server do
  use GRPC.Server, service: Helloworld.Greeter.Service

  @spec say_hello(Helloworld.HelloRequest.t(), GRPC.Server.Stream.t()) ::
          Helloworld.HelloReply.t()
  def say_hello(request, _stream) do
    nanos_epoch = System.system_time() |> System.convert_time_unit(:native, :nanosecond)
    seconds = div(nanos_epoch, 1_000_000_000)
    nanos = nanos_epoch - seconds * 1_000_000_000

    reply = %Helloworld.HelloReply{
      message: "Hello #{request.name}",
      today: %Google.Protobuf.Timestamp{seconds: seconds, nanos: nanos}
    }

    # use this for proto2, if you are testing with proto3, comment this out
    reply =
      reply
      |> Helloworld.HelloReply.put_extension(
        Helloworld.PbExtension,
        :extend_message,
        "extended message"
      )
      |> Helloworld.HelloReply.put_extension(Helloworld.PbExtension, :extend_number, 1024)
      |> Helloworld.HelloReply.put_extension(Helloworld.PbExtension, :tracer, %Helloworld.Tracer{
        id: 1,
        name: "name"
      })

    reply
  end
end
