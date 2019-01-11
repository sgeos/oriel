defmodule OrielWeb.GraphQL.Types do
  use Absinthe.Schema.Notation

  @desc """
  Pong
  """
  object :pong do
    field :success, :boolean
    field :pong, :string # "pong"
    field :date, :date # date when message is generated
    field :time, :time # time when message is generated
    field :datetime, :datetime # date and time when message is generated
  end

  object :info do
    field :date, :date
    field :datetime, :datetime
    field :node, :string
    field :node_list, list_of(:string)
    field :node_visible, list_of(:string)
    field :time, :time
    field :ttl, :integer
    field :ttl_heartbeat, :integer
    field :remote_ip, :ip_address
    field :version, :string
  end

  object :item do
    field :item_id, non_null(:string)
    field :owner_id, non_null(:string)
    field :type, non_null(:string)
    field :position, non_null(:string)
    field :remote_ip, non_null(:ip_address)
    field :created_at, non_null(:datetime)
    field :updated_at, non_null(:datetime)
  end

  input_object :create_item_input do
    field :item_id, non_null(:string)
    field :owner_id, non_null(:string)
    field :type, non_null(:string)
    field :position, non_null(:string)
  end

  input_object :read_item_input do
    field :item_id, non_null(:string)
    field :owner_id, non_null(:string)
  end

  input_object :update_item_input do
    field :item_id, non_null(:string)
    field :owner_id, non_null(:string)
    field :type, :string
    field :position, :string
  end

  input_object :delete_item_input do
    field :item_id, non_null(:string)
    field :owner_id, non_null(:string)
  end

  @desc """
  The `IP Address` scalar type represents ip address values.
  """
  scalar :ip_address do
    description "IP address stored as a tuple",
    parse &(&1) # identity
    serialize &(to_string(:inet_parse.ntoa(&1)))
  end

  @desc """
  The `Date` scalar type represents date values.
  """
  scalar :date do
    description "ISOz date",
    parse fn input ->
      input.value
      |> Kernel.to_string
      |> String.replace("/", "-")
      |> Date.from_iso8601!
      |> Timex.to_unix
    end
    #serialize &Kernel.to_string/1
    serialize &(&1 |> Timex.from_unix |> DateTime.to_date |> Kernel.to_string)
  end

  @desc """
  The `Time` scalar type represents time values.
  """
  scalar :time do
    description "ISOz time",
    parse fn input ->
      input.value
      |> Kernel.to_string
      |> Time.from_iso8601!
      |> Timex.Duration.from_time
      |> Timex.Duration.to_seconds
    end
    #serialize &Kernel.to_string/1
    serialize &(&1 |> Timex.Duration.from_seconds |> Timex.Duration.to_time! |> Kernel.to_string)
  end

  @desc """
  The `Datetime` scalar type represents date time values.
  """
  scalar :datetime do
    description "ISOz datetime",
    parse fn input ->
      input.value
      |> Kernel.to_string
      |> String.replace("/", "-")
      |> Timex.parse!("{ISO:Extended}")
      |> Timex.Timezone.convert("UTC")
      |> Timex.to_unix
    end
    #serialize fn time -> time |> Timex.format("%F %T", :strftime) end
    serialize &(&1 |> Timex.from_unix |> Kernel.to_string)
  end
end

