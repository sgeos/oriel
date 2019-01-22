defmodule Oriel.Cache.Server do
  use GenServer
  alias Oriel.Config
  alias Oriel.Cache.Store

  @application :oriel
  @timeout (1 * 60 * 1000)

  ## Utility Functions

  #defp get_setting(map, key) do
  #  map
  #  |> Enum.into(%{})
  #  |> Map.get(key)
  #  |> Kernel.||(Config.get(@application, key))
  #end

  defp get_setting_integer(map, key) do
    map
    |> Enum.into(%{})
    |> Map.get(key)
    |> Kernel.||(Config.get_integer(@application, key))
  end

  defp get_setting_list(map, key) do
    map
    |> Enum.into(%{})
    |> Map.get(key)
    |> Kernel.||(Config.get_list(@application, key))
  end

  defp next_ttl_expire(%{ttl_heartbeat: ttl_heartbeat}=state) do
    ttl_timer = Process.send_after(self(), :ttl, ttl_heartbeat)
    state
    |> Map.merge(%{ttl_timer: ttl_timer})
  end

  defp get_version(application \\ @application) do
      :application.get_key(application, :vsn)
      |> case do
        {:ok, version} ->
          version
	  |> to_string
        _
          -> "unknown"
      end
  end

  ## Client API

  def start_link(opts) do
    options = %{name: __MODULE__}
    |> Map.merge(opts |> Enum.into(%{}))
    |> Enum.into([])
    init_args = %{
      node_list: get_setting_list(options, :node_list),
      ttl: get_setting_integer(options, :ttl),
      ttl_heartbeat: get_setting_integer(options, :ttl_heartbeat),
      version: get_version(),
    }
    GenServer.start_link(__MODULE__, init_args, options)
  end

  def info(), do: GenServer.call(__MODULE__, :info)
  def info(server), do: GenServer.call(server, :info)

  def create(input), do: GenServer.call(__MODULE__, {:create, input})
  def create(server, input), do: GenServer.call(server, {:create, input})

  def read(input), do: GenServer.call(__MODULE__, {:read, input})
  def read(server, input), do: GenServer.call(server, {:read, input})

  def update(input), do: GenServer.call(__MODULE__, {:update, input})
  def update(server, input), do: GenServer.call(server, {:update, input})

  def delete(input), do: GenServer.call(__MODULE__, {:delete, input})
  def delete(server, input), do: GenServer.call(server, {:delete, input})

  def get_items_by_id(input), do: GenServer.call(__MODULE__, {:get_items_by_id, input})
  def get_items_by_id(server, input), do: GenServer.call(server, {:get_items_by_id, input})

  def ttl_expire(), do: ttl_expire(__MODULE__)
  def ttl_expire(server) do
    send(server, :ttl)
    :ok
  end

  ## Server Callbacks

  def init(state), do: {:ok, next_ttl_expire(state)}

  def handle_call(:info, _from, state) do
    reply = state
    |> Map.merge(Store.info())
    {:reply, reply, state, @timeout}
  end

  def handle_call({:create, input}, _from, state), do: {:reply, Store.create(input), state, @timeout}

  def handle_call({:read, input}, _from, state), do: {:reply, Store.read(input), state, @timeout}

  def handle_call({:update, input}, _from, state), do: {:reply, Store.update(input), state, @timeout}

  def handle_call({:delete, input}, _from, state), do: {:reply, Store.delete(input), state, @timeout}

  def handle_call({:get_items_by_id, input}, _from, state), do: {:reply, Store.get_items_by_id(input), state, @timeout}

  def handle_call(_msg, state), do: {:noreply, state, @timeout}

  def handle_cast(_msg, state), do: {:noreply, state, @timeout}

  def handle_info(:ttl, %{ttl: ttl, ttl_timer: ttl_timer}=state) do
    Process.cancel_timer(ttl_timer)
    Store.ttl_expire(ttl)
    {:noreply, next_ttl_expire(state), @timeout}
  end

  def handle_info(_msg, state), do: {:noreply, state, @timeout}
end

