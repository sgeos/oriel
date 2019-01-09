defmodule OrielWeb.Router do
  use OrielWeb, :router
  alias OrielWeb.{ApiController, GraphQL}

  pipeline :graphql do
    plug :accepts, ["json", "graphql"]
    plug Oriel.Plug.AbsintheRemoteIp
  end

  scope "/" do
    pipe_through :graphql

    match :*, "/healthz", ApiController, :healthz
    match :*, "/", Absinthe.Plug.GraphiQL, schema: GraphQL.Schema, json_codec: Phoenix.json_library(), interface: :simple
    forward "/graphql", Absinthe.Plug, schema: GraphQL.Schema, json_codec: Phoenix.json_library()
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: GraphQL.Schema, json_codec: Phoenix.json_library()
  end
end

