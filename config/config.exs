# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Application configuration
config :oriel,
  ttl: {:system, "TTL", 1*24*60*60}, # seconds
  ttl_heartbeat: {:system, "TTL_HEARTBEAT", 1000}, # milliseconds
  node_list: {:system, "NODE_LIST"}

# Configures the endpoint
config :oriel, OrielWeb.Endpoint,
  http: [port: System.get_env("PORT") || 8080],
  url: [host: System.get_env("HOST") || "localhost", port: {:system, "PORT"}],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "lWzQPQn5HBKrkRom+RWkpmZ4zaN1PEDwlfwlKHsxnLBpiwptT4WqPz4r/ppE0QDv",
  render_errors: [view: OrielWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Oriel.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mnesia,
  dir: '/etc/.mnesia/#{Mix.env}/#{node()}'        # Notice the single quotes
  #dir: '.mnesia/#{Mix.env}/#{node()}'        # Notice the single quotes

config :mnesiac,
  stores: [Oriel.Cache.Store],
  schema_type: :disc_copies,
  table_load_timeout: 600_000 # milliseconds

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

