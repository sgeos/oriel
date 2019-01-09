defmodule OrielWeb.GraphQL.Schema do
  use Absinthe.Schema
  import_types OrielWeb.GraphQL.Types
  alias OrielWeb.GraphQL.Resolver

  query do
    field :ping, type: :pong do
      resolve &Resolver.ping/2
    end

    field :info, type: :info do
      resolve &Resolver.info/2
    end
  end

  #mutation do
  #end
end

