defmodule NoDescriptor.ImportsTest.UserRequest do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.UserRequest",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :name, 1, type: :string
  field :email, 2, type: :string
  field :address, 3, type: Common.Address
  field :location, 4, type: Common.Coordinates
  field :registered_at, 5, type: Google.Protobuf.Timestamp, json_name: "registeredAt"
end

defmodule NoDescriptor.ImportsTest.UserResponse.Profile do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.UserResponse.Profile",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :billing_address, 1, type: Common.Address, json_name: "billingAddress"
  field :shipping_address, 2, type: Common.Address, json_name: "shippingAddress"

  field :recent_locations, 3,
    repeated: true,
    type: Common.Coordinates,
    json_name: "recentLocations"
end

defmodule NoDescriptor.ImportsTest.UserResponse do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.UserResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :user_id, 1, type: :string, json_name: "userId"
  field :priority, 2, type: Common.Priority, enum: true
  field :created_at, 3, type: Google.Protobuf.Timestamp, json_name: "createdAt"
  field :profile, 4, type: NoDescriptor.ImportsTest.UserResponse.Profile
end

defmodule NoDescriptor.ImportsTest.LocationUpdate do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.LocationUpdate",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :user_id, 1, type: :string, json_name: "userId"
  field :new_location, 2, type: Common.Coordinates, json_name: "newLocation"
  field :timestamp, 3, type: Google.Protobuf.Timestamp
end

defmodule NoDescriptor.ImportsTest.LocationResponse.VisitHistoryEntry do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.LocationResponse.VisitHistoryEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Common.TimeRange
end

defmodule NoDescriptor.ImportsTest.LocationResponse do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.LocationResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :success, 1, type: :bool
  field :confirmed_location, 2, type: Common.Coordinates, json_name: "confirmedLocation"

  field :visit_history, 3,
    repeated: true,
    type: NoDescriptor.ImportsTest.LocationResponse.VisitHistoryEntry,
    json_name: "visitHistory",
    map: true
end

defmodule NoDescriptor.ImportsTest.BulkOperation.TaskPrioritiesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.BulkOperation.TaskPrioritiesEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Common.Priority, enum: true
end

defmodule NoDescriptor.ImportsTest.BulkOperation do
  @moduledoc false

  use Protobuf,
    full_name: "imports_test.BulkOperation",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :addresses, 1, repeated: true, type: Common.Address
  field :transactions, 2, repeated: true, type: Common.Money

  field :task_priorities, 3,
    repeated: true,
    type: NoDescriptor.ImportsTest.BulkOperation.TaskPrioritiesEntry,
    json_name: "taskPriorities",
    map: true
end

defmodule NoDescriptor.ImportsTest.ImportTestService.Service do
  @moduledoc false

  use GRPC.Service, name: "imports_test.ImportTestService", protoc_gen_elixir_version: "0.16.0"

  rpc :CreateUser, NoDescriptor.ImportsTest.UserRequest, NoDescriptor.ImportsTest.UserResponse

  rpc :UpdateLocation,
      NoDescriptor.ImportsTest.LocationUpdate,
      NoDescriptor.ImportsTest.LocationResponse
end

defmodule NoDescriptor.ImportsTest.ImportTestService.Stub do
  @moduledoc false

  use GRPC.Stub, service: NoDescriptor.ImportsTest.ImportTestService.Service
end
