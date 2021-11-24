use Mix.Config

# Configure your database
config :auth, Auth.Repo,
  username: "postgres",
  password: "postgres",
  database: "auth_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :auth, AuthWeb.Endpoint,
  http: [port: 4002],
  server: true # https://elixirforum.com/t/wallaby-with-phoenix-1-16-rc0/42352/9

# Print only warnings and errors during test
config :logger, level: :warn

config :elixir_auth_google,
  client_id: "631770888008-6n0oruvsm16kbkqg6u76p5cv5kfkcekt.apps.googleusercontent.com",
  client_secret: "MHxv6-RGF5nheXnxh1b0LNDq",
  httpoison_mock: true

config :auth_plug,
  api_key: System.get_env("AUTH_API_KEY"),
    # "2PzB7PPnpuLsbWmWtXpGyI+kfSQSQ1zUW2Atz/+8PdZuSEJzHgzGnJWV35nTKRwx/authdev.herokuapp.com",
  httpoison_mock: true