defmodule Auth.Mixfile do
  use Mix.Project

  def project do
    [
      app: :auth,
      version: "1.5.0",
      elixir: "~> 1.12.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        c: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [plt_add_deps: :transitive],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      description: "Turnkey Auth Auth Application"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Auth.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix core:
      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.16.4"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18.2"},
      {:jason, "~> 1.2.2"},
      {:plug_cowboy, "~> 2.5.2"},

      # Auth:
      # https://github.com/dwyl/elixir-auth-github
      {:elixir_auth_github, "~> 1.5.0"},
      # https://github.com/dwyl/elixir-auth-google
      {:elixir_auth_google, "~> 1.5.0"},
      # https://github.com/dwyl/auth_plug
      {:auth_plug, "~> 1.3.0"},
      # https://github.com/dwyl/rbac
      {:rbac, "~> 0.5.3"},

      # Field Validation and Encryption: github.com/dwyl/fields
      {:fields, "~> 2.8.2"},
      # Base58 Encodeing: https://github.com/dwyl/base58
      {:B58, "~> 1.0", hex: :b58},
      # Useful functions: https://github.com/dwyl/useful
      {:useful, "~> 0.2.0"},

      # Ping to Wake Heroku Instance: https://github.com/dwyl/ping
      {:ping, "~> 1.1.0"},

      # Check test coverage
      {:excoveralls, "~> 0.12.3", only: :test},

      #  Property based tests: github.com/dwyl/learn-property-based-testing
      {:stream_data, "~> 0.4.3", only: :test},

      # Create Documentation for publishing Hex.docs:
      {:ex_doc, "~> 0.21.3", only: :dev},
      {:credo, "~> 1.4", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:sobelow, "~> 0.10.2", only: [:dev]}
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
      c: ["coveralls.html"],
      "ecto.setup": ["ecto.create --quiet", "ecto.migrate --quiet", "seeds"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      seeds: ["run priv/repo/seeds.exs"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end

  defp package() do
    [
      files: ~w(lib LICENSE mix.exs README.md),
      name: "auth",
      licenses: ["GNU GPL v2.0"],
      maintainers: ["dwyl"],
      links: %{"GitHub" => "https://github.com/dwyl/auth"}
    ]
  end
end


