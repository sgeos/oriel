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
    field :fragment_properties, list_of(:fragment_properties)
    field :time, :time
    field :ttl, :duration
    field :ttl_heartbeat, :duration
    field :remote_ip, :ip_address
    field :version, :string
  end

  object :fragment_properties do
    field :base_table, :string
    field :foreign_key, :string
    field :hash_module, :string
    field :hash_state, :string
    #field :hash_state: {:hash_state, 32, 1, 5, :phash2},
    field :n_fragments, :integer
    field :node_pool, list_of(:string)
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

  input_object :search_item_input do
    field :item_id, :string
    field :owner_id, :string
    field :type, :string
    field :position, :string
    field :remote_ip, :ip_address
    field :created_at, :datetime
    field :updated_at, :datetime
  end

  defp parse_ok(input), do: {:ok, input}

  @desc """
  The `IP Address` scalar type represents ip address values.
  """
  scalar :ip_address do
    description "IP address stored as a tuple",
    parse fn input ->
      input.value
      |> String.to_charlist
      |> :inet.parse_address
    end
    serialize &(to_string(:inet_parse.ntoa(&1)))
  end

  @desc """
  The `Duration` scalar type represents ISO 8601 duration values.
  """
  scalar :duration do
    description "ISOz date",
    parse &(Timex.Duration.parse(&1.value))
    serialize &Timex.Duration.to_string/1
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
      |> parse_ok
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
      |> parse_ok
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
      |> parse_ok
    end
    #serialize fn time -> time |> Timex.format("%F %T", :strftime) end
    serialize &(&1 |> Timex.from_unix |> Kernel.to_string)
  end
end

