defmodule Auth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AuthWeb.Telemetry,
      # Start the Ecto repository
      Auth.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Auth.PubSub},
      # Start Finch
      {Finch, name: Auth.Finch},
      # Start the Endpoint (http/https)
      AuthWeb.Endpoint
      # Start a worker by calling: Auth.Worker.start_link(arg)
      # {Auth.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AuthWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
