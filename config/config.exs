# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :forza_challenge_demo,
  namespace: FCDemo,
  ecto_repos: [FCDemo.Repo],
  env: config_env()

# Configures the endpoint
config :forza_challenge_demo, FCDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FGWc6vD+2xVmBMvlWPPw+m/DLsdNl9XvyM2vXJysPXS2YMKX68cNL+XYUoUgM2ca",
  render_errors: [view: FCDemoWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: FCDemo.PubSub,
  live_view: [signing_salt: "56ojXLmv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
