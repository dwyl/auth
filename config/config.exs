# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :auth,
  ecto_repos: [Auth.Repo]

# Configures the endpoint
config :auth, AuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jUgd/S8tmMjbhzawyKI8ns2C3RbS04n0ClDVrLa7KjHLgDfcFJ6FS60BhvWBw/cg",
  render_errors: [view: AuthWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Auth.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Ueberauth providers
# config :ueberauth, Ueberauth,
#   providers: [
#     github: {Ueberauth.Strategy.Github, []}
#   ]

# config :ueberauth, Ueberauth.Strategy.Github.OAuth,
#   client_id: System.get_env("GITHUB_CLIENT_ID"),
#   client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Configure email via AWS SES
config :auth, Auth.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SES_SERVER"),
  port: System.get_env("SES_PORT"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  # can be `:always` or `:never`
  tls: :always,
  # can be `true`
  ssl: false,
  retries: 1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
