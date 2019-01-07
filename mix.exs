defmodule Auth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :auth,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Auth.Application, []},
      extra_applications: [
        # auth specific:
        :ueberauth,
        :ueberauth_identity,
        # email
        :bamboo,
        # password encryption/checking for :ueberauth_identity
        :comeonin
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    # Phoenix core:
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      # Auth:
      # github.com/ueberauth/ueberauth
      {:ueberauth, "~> 0.4"},
      # github.com/ueberauth/ueberauth_identity
      {:ueberauth_identity, "~> 0.2"},

      # Email Sent by AWS SES see: https://git.io/vSuqc
      # github.com/thoughtbot/bamboo
      {:bamboo, "~> 0.7"},
      # github.com/fewlinesco/bamboo_smtp
      {:bamboo_smtp, "~> 1.2.1"},

      # Password Hashing
      # github.com/riverrun/comeonin (bcrypt)
      {:comeonin, "~> 2.0"},

      # Dev/Test only:
      # for checking test coverage
      {:excoveralls, "~> 0.6", only: :test},
      # for testing email without sending any
      {:mock, "~> 0.2.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
