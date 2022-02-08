# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :auth,
  ecto_repos: [Auth.Repo]

# Configures the endpoint
config :auth, AuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: AuthWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Auth.PubSub,
  live_view: [signing_salt: "G+UI6RIv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# https://hexdocs.pm/joken/introduction.html#usage
config :joken, default_signer: System.get_env("SECRET_KEY_BASE")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# https://gist.github.com/chrismccord/2ab350f154235ad4a4d0f4de6decba7b
# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :auth_plug,
  api_key: System.get_env("AUTH_API_KEY")