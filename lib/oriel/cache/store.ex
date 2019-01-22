defmodule Oriel.Cache.Store do
  @moduledoc """
  Cache store implementation.
  """
  require Record

  @table_wait_time 10_000 # milliseconds

  Record.defrecord(
    :item_key,
    item_id: nil,
    owner_id: nil
  )

  @type item_key ::
    record(
      :item_key,
      item_id: String.t(),
      owner_id: String.t()
    )

  Record.defrecord(
    :item_key_owner_search,
    item_id: nil,
    owner_id_list: []
  )

  @type item_key_owner_search ::
    record(
      :item_key_owner_search,
      item_id: String.t(),
      owner_id_list: list(String.t())
    )

  Record.defrecord(
    :item,
    key: {:item_key, nil, nil},
    type: nil,
    position: nil,
    remote_ip: nil,
    created_at: nil,
    updated_at: nil
  )

  @type item ::
    record(
      :item,
      key: item_key,
      type: String.t(),
      position: String.t(),
      remote_ip: tuple(),
      created_at: non_neg_integer(),
      updated_at: non_neg_integer()
    )

  ## Mnesiac Callbacks

  @doc """
  Mnesiac will call this method to initialize the table
  """
  def init_store do
    :mnesia.create_table(
      :item,
      attributes: store_keys(:item),
      index: [:updated_at],
      disc_copies: [Node.self()]
    )
    :mnesia.create_table(
      :item_key_owner_search,
      attributes: store_keys(:item_key_owner_search),
      disc_copies: [Node.self()]
    )
  end

  @doc """
  Mnesiac will call this method to copy the table
  """
  def copy_store do
    :mnesia.add_table_copy(:item, Node.self(), :disc_copies)
    :mnesia.add_table_copy(:item_key_owner_search, Node.self(), :disc_copies)
  end

  ## Utility Functions

  defp created_now do
    time = DateTime.utc_now
    |> Timex.to_unix
    %{created_at: time, updated_at: time}
  end

  defp updated_now, do: %{updated_at: DateTime.utc_now |> Timex.to_unix}

  defp store_keys(:item) do
    item()
    |> item()
    |> Keyword.keys()
  end

  defp store_keys(:item_key) do
    item_key()
    |> item_key()
    |> Keyword.keys()
  end

  defp store_keys(:item_key_owner_search) do
    item_key_owner_search()
    |> item_key_owner_search()
    |> Keyword.keys()
  end

  defp store_record(input, :item), do: input |> item()
  defp store_record(input, :inline_item) do
    result = input
    |> item()
    key = result
    |> Keyword.get(:key)
    |> store_record(:item_key)
    result
    |> Keyword.put(:key, key)
  end
  defp store_record(input, :item_key), do: input |> item_key()
  defp store_record(input, :item_key_owner_search), do: input |> item_key_owner_search()

  defp nest_map_key_field(map, key) do
    new_key = map
    |> Map.get(:key, %{})
    |> Map.put(key, map[key])
    map
    |> Map.put(:key, new_key)
    |> Map.delete(key)
  end

  defp nest_map_key(map, fields) when is_list(fields) do
    fields
    |> Enum.reduce(map, fn key, map -> map |> nest_map_key_field(key) end)
  end
  defp nest_map_key(map, :item), do: map |> nest_map_key(store_keys(:item_key))
  defp nest_map_key(map, _type), do: map

  defp unnest_map_key(%{key: key}=map) do
    map
    |> Map.merge(key)
    |> Map.delete(:key)
  end
  defp unnest_map_key(map), do: map

  # NOTE: :key is hard coded because it is a nested special case
  defp extract_value(input, :key) do
    input[:key]
    |> map_to_store_record(:item_key)
  end
  defp extract_value(input, key), do: input[key]

  defp map_to_store_record(input, type \\ :item) do
    nested_input = input
    |> nest_map_key(type)
    store_keys(type)
    |> Enum.map(fn key -> nested_input |> extract_value(key) end)
    |> List.insert_at(0, type)
    |> List.to_tuple
  end

  defp store_record_to_map(input) when Record.is_record(input) do
    type = input
    |> elem(0)
    input
    |> store_record(type)
    |> Enum.map(fn {k, v} -> {k, v |> store_record_to_map} end)
    |> Enum.into(%{})
    |> unnest_map_key()
  end
  defp store_record_to_map(input), do: input

  defp do_map(list, action) do
    list
    |> Enum.map(action)
    |> Enum.filter(fn r -> !is_nil(r) end)
  end

  defp mnesia_transaction(input, callback) when is_map(input) do
    :mnesia.transaction(fn -> callback.(input) end)
    |> mnesia_result
  end
  defp mnesia_transaction(input, callback) when is_list(input) do
    :mnesia.transaction(fn -> input |> do_map(callback) end)
    |> mnesia_result
  end

  defp mnesia_raw_transaction(input, callback) do
    :mnesia.transaction(fn -> callback.(input) end)
    |> mnesia_result
  end

  defp mnesia_result(result) do
    case result do
      {:atomic, result} ->
        result
      {:aborted, {exception, stacktrace}} ->
        :error
        |> Exception.normalize(exception)
        |> reraise(stacktrace)
      {:aborted, error} ->
        throw(error)
      result ->
        result
    end
  end

  ## Client API

  def info do
    :mnesia.system_info
    |> Enum.into(%{})
    |> Map.merge(%{
      node: node() |> to_string,
      node_visible: [node() | Node.list(:visible)] |> Enum.map(&to_string/1),
    })
  end

  def ttl_expire(_input), do: :stub # TODO: write

  def get_item_owners(%{item_id: key}) do
    {:item_key_owner_search, key}
    |> :mnesia.read()
    |> List.first
    |> case do
      {:item_key_owner_search, ^key, search_id_list} ->
        search_id_list
      nil ->
        []
    end
  end

  defp get_items_by_id_transaction(input) do
    input
    |> Enum.map(&({&1, get_item_owners(%{item_id: &1})}))
    |> Enum.map(fn {item_id, list} -> list |> Enum.map(&({:item_key, item_id, &1})) end)
    |> Enum.reduce([], &Kernel.++/2)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(&(:mnesia.read({:item, &1})))
    |> Enum.reduce([], &Kernel.++/2)
    |> Enum.map(&store_record_to_map/1)
  end

  def get_items_by_id(input), do: input |> mnesia_raw_transaction(&get_items_by_id_transaction/1)

  defp append_search_id(%{item_id: key, owner_id: search_id}=input) do
    input
    |> get_item_owners()
    |> Kernel.++([search_id])
    |> Enum.uniq
    |> case do
      search_id_list ->
        :mnesia.write({:item_key_owner_search, key, search_id_list})
    end
  end

  defp remove_search_id(%{item_id: key, owner_id: search_id}=input) do
    input
    |> get_item_owners()
    |> Kernel.--([search_id])
    |> case do
      [] ->
        :mnesia.delete({:item_key_owner_search, key})
      search_id_list ->
        :mnesia.write({:item_key_owner_search, key, search_id_list})
    end
  end

  defp create_or_update_transaction(input) do
    record = input
    |> map_to_store_record()
    :mnesia.write(record)
    |> case do
      :ok ->
        append_search_id(input)
        store_record_to_map(record)
      _ ->
        #{:error, "Failed to create record."}
        nil
    end
  end

  defp create_transaction(input) do
    input
    |> read_transaction
    |> case do
      nil ->
        input
        |> Map.merge(created_now())
        |> create_or_update_transaction()
      _existing ->
        #existing
        #{:error, "Record with key {input_id: #{input[:item_id]}, owner_id: #{input[:owner_id]}} already exists."}
        nil
    end
  end

  def create(input), do: input |> mnesia_transaction(&create_transaction/1)

  defp read_transaction(input) do
    key = input
    |> map_to_store_record(:item_key)
    :mnesia.read({:item, key})
    |> List.first
    |> store_record_to_map()
  end

  def read(input), do: input |> mnesia_transaction(&read_transaction/1)

  defp update_transaction(input) do
    input
    |> read_transaction
    |> case do
      nil ->
        #{:error, "Record with key {input_id: #{input[:item_id]}, owner_id: #{input[:owner_id]}} does not exist."}
        nil
      existing ->
        existing
        |> Map.merge(input)
        |> Map.merge(updated_now())
        |> create_or_update_transaction()
    end
  end

  def update(input), do: input |> mnesia_transaction(&update_transaction/1)

  defp delete_transaction(input) do
    input
    |> read_transaction
    |> case do
      nil ->
        #{:error, "Record with key {input_id: #{input[:item_id]}, owner_id: #{input[:owner_id]}} does not exist."}
        nil
      existing ->
        :mnesia.delete({:item, input |> map_to_store_record(:item_key)})
        remove_search_id(input)
        existing
    end
  end

  def delete(input), do: input |> mnesia_transaction(&delete_transaction/1)

  def auto_setup_disc_database(nodes) do
    if path = Application.get_env(:mnesia, :dir) do
      :ok = File.mkdir_p!(path)
    end
    :mnesia.create_schema(nodes)
    :mnesia.wait_for_tables([:item, :item_key_owner_search], @table_wait_time)
  end
end

