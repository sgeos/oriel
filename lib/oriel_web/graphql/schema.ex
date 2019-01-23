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

    field :item, type: :item do
      arg :item, non_null(:read_item_input)
      resolve &Resolver.Item.read(&1, &2, &3)
    end

    field :items, type: list_of(:item) do
      arg :items, non_null(list_of(:read_item_input))
      resolve &Resolver.Item.read(&1, &2, &3)
    end

    field :get_items_by_id, type: list_of(:item) do
      arg :item_id, non_null(:string)
      resolve &Resolver.Item.get_items_by_id(&1, &2, &3)
    end

    field :get_items_by_ids, type: list_of(:item) do
      arg :item_ids, non_null(list_of(:string))
      resolve &Resolver.Item.get_items_by_id(&1, &2, &3)
    end

    field :search, type: list_of(:item) do
      arg :item, non_null(:search_item_input)
      resolve &Resolver.Item.search(&1, &2, &3)
    end

    field :search_union, type: list_of(:item) do
      arg :items, non_null(list_of(:search_item_input))
      resolve &Resolver.Item.search(&1, &2, &3)
    end
  end

  mutation do
    field :create_item, type: :item do
      arg :item, non_null(:create_item_input)
      resolve &Resolver.Item.create(&1, &2, &3)
    end

    field :create_items, type: list_of(:item) do
      arg :items, non_null(list_of(:create_item_input))
      resolve &Resolver.Item.create(&1, &2, &3)
    end

    field :update_item, type: :item do
      arg :item, non_null(:update_item_input)
      resolve &Resolver.Item.update(&1, &2, &3)
    end

    field :update_items, type: list_of(:item) do
      arg :items, non_null(list_of(:update_item_input))
      resolve &Resolver.Item.update(&1, &2, &3)
    end

    field :delete_item, type: :item do
      arg :item, non_null(:delete_item_input)
      resolve &Resolver.Item.delete(&1, &2, &3)
    end

    field :delete_items, type: list_of(:item) do
      arg :items, non_null(list_of(:delete_item_input))
      resolve &Resolver.Item.delete(&1, &2, &3)
    end
  end
end

