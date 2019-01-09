defmodule OrielWeb.GraphQL.Resolver do
  alias Oriel.Config

  defp application_key_as_string(key, default \\ "(unknown)") do
    :application.get_key(:oriel, key)
    |> case do
      {:ok, result} ->
        result
      _ ->
        default
    end
    |> to_string
  end

  defp datetime_set_now, do: DateTime.utc_now |> datetime_set

  defp datetime_set(datetime) do
    %{
      datetime: datetime
      |> Timex.to_unix,
      date: datetime
      |> DateTime.to_date
      |> Timex.to_unix,
      time: datetime
      |> DateTime.to_time
      |> Timex.Duration.from_time
      |> Timex.Duration.to_seconds
    }
  end

  def ping(_args, _info) do
    {:ok, Map.merge(%{success: true, pong: "pong"}, datetime_set_now())}
  end

  def info(_args, %{context: %{remote_ip: remote_ip}}=_info) do
    result = %{
      node: node() |> to_string,
      node_list: [node() | Node.list()] |> Enum.map(&to_string/1),
      node_visible: [node() | Node.list(:visible)] |> Enum.map(&to_string/1),
      remote_ip: remote_ip,
      ttl: Config.get_integer(:oriel, :ttl),
      ttl_heartbeat: Config.get_integer(:oriel, :ttl_heartbeat),
      version: application_key_as_string(:vsn)
    }
    {:ok, Map.merge(result, datetime_set_now())}
  end
end

