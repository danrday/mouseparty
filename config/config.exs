# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mouseparty,
  ecto_repos: [Mouseparty.Repo]

# Configures the endpoint
config :mouseparty, MousepartyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2jEkw86oKlGEi5uuFU7RWWCpo4QWf2mUU3h6pYAZTZh5n4PZ+j46p6YrAsID8hgL",
  render_errors: [view: MousepartyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mouseparty.PubSub,
  live_view: [signing_salt: "r7F017wN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
