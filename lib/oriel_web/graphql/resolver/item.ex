defmodule OrielWeb.GraphQL.Resolver.Item do
  alias alias Oriel.Cache.Server, as: Server

  def create(_parent, %{item: item}=_args, %{context: %{remote_ip: remote_ip}}=_info) do
    {:ok, Server.create(item |> Map.merge(%{remote_ip: remote_ip}))}
  end

  def create(_parent, %{items: items}=_args, %{context: %{remote_ip: remote_ip}}=_info) do
    {:ok, Server.create(items |> Enum.map(fn i -> i |> Map.merge(%{remote_ip: remote_ip}) end))}
  end

  def read(_parent, %{item: item}=_args, _info), do: {:ok, Server.read(item)}
  def read(_parent, %{items: items}=_args, _info), do: {:ok, Server.read(items)}

  def update(_parent, %{item: item}=_args, _info), do: {:ok, Server.update(item)}
  def update(_parent, %{items: items}=_args, _info), do: {:ok, Server.update(items)}

  def delete(_parent, %{item: item}=_args, _info), do: {:ok, Server.delete(item)}
  def delete(_parent, %{items: items}=_args, _info), do: {:ok, Server.delete(items)}

  def get_items_by_id(_parent, %{item_id: item_id}=_args, _info), do: {:ok, Server.get_items_by_id([item_id])}
  def get_items_by_id(_parent, %{item_ids: item_ids}=_args, _info), do: {:ok, Server.get_items_by_id(item_ids)}

  def search(_parent, %{item: item}=_args, _info), do: {:ok, Server.search([item])}
  def search(_parent, %{items: items}=_args, _info), do: {:ok, Server.search(items)}
end

