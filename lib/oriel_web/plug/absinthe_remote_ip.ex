defmodule Oriel.Plug.AbsintheRemoteIp do
  def init(options), do: options

  def call(conn, _) do
    context = %{remote_ip: conn.remote_ip}
    Absinthe.Plug.put_options(conn, context: context)
  end
end

