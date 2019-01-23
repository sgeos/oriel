defmodule Oriel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Oriel.Config
  alias Oriel.Cache.Store

  defp init_nodes(nodes) do
    IO.puts("Starting node: #{node() |> inspect}")
    IO.puts("Node set: #{nodes |> inspect}")
    Store.auto_setup_disc_database(nodes)
    Mnesiac.init_mnesia(nodes)
  end

  def start(_type, _args) do
    this_node = [node()]
    init_nodes(this_node)
    nodes = Config.get_atom_list(:oriel, :node_list, [node()])
    topologies = [
      epmd: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: nodes],
        connect: {:net_kernel, :connect_node, []},
        disconnect: {:erlang, :disconnect_node, []},
        list_nodes: {:erlang, :nodes, [:connected]},
      ]
    ]

    # List all child processes to be supervised
    children = [
      {Cluster.Supervisor, [topologies, [name: Oriel.ClusterSupervisor]]},
      {Mnesiac.Supervisor, [nodes, [name: Oriel.MnesiacSupervisor]]},
      Oriel.Cache.Server,
      OrielWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Oriel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OrielWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
