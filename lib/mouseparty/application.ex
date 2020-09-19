defmodule Mouseparty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # import Supervisor.Spec

    children = [
      # Start the Ecto repository
      Mouseparty.Repo,
      # Start the Telemetry supervisor
      MousepartyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mouseparty.PubSub},
      # Start the Endpoint (http/https)
      MousepartyWeb.Presence,
      MousepartyWeb.Endpoint
      # Start a worker by calling: Mouseparty.Worker.start_link(arg)
      # {Mouseparty.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mouseparty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MousepartyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
