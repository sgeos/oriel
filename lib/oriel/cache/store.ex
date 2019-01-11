defmodule Oriel.Cache.Store do
  @moduledoc """
  Cache store implementation.
  """
  require Record

  Record.defrecord(
    :item,
    __MODULE__,
    item_id: nil,
    owner_id: nil,
    type: nil,
    position: nil,
    remote_ip: nil,
    created_at: nil,
    updated_at: nil
  )

  @type item ::
    record(
      :item,
      item_id: String.t(),
      owner_id: String.t(),
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
      __MODULE__,
      attributes: item() |> item() |> Keyword.keys(),
      index: [:owner_id, :updated_at],
      disc_copies: [Node.self()]
    )
  end

  @doc """
  Mnesiac will call this method to copy the table
  """
  def copy_store do
    :mnesia.add_table_copy(__MODULE__, Node.self(), :disc_copies)
  end

  ## Utility Functions

  defp created_now do
    time = DateTime.utc_now
    |> Timex.to_unix
    %{created_at: time, updated_at: time}
  end

  defp updated_now, do: %{updated_at: DateTime.utc_now |> Timex.to_unix}

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

  defp stub do # TODO: delete after real functions are written
    %{
      item_id: "stub",
      owner_id: "stub",
      type: "stub",
      position: "stub",
      remote_ip: {0,0,0,0},
    }
    |> Map.merge(created_now())
  end

  def create(_input), do: stub() # TODO: write
  def read(_input), do: stub() # TODO: write
  def update(_input), do: stub() |> Map.merge(updated_now()) # TODO: write
  def delete(_input), do: stub() # TODO: write

  def auto_setup_disc_database(_input), do: :stub # TODO: write
end

