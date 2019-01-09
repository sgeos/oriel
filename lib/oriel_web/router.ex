defmodule OrielWeb.Router do
  use OrielWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OrielWeb do
    pipe_through :api
  end
end
