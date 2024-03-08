defmodule Polaroids.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PolaroidsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:polaroids, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Polaroids.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Polaroids.Finch},
      # Start a worker by calling: Polaroids.Worker.start_link(arg)
      # {Polaroids.Worker, arg},
      # Start to serve requests, typically the last entry
      PolaroidsWeb.Endpoint,
      {Cachex, name: :image_cache}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Polaroids.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PolaroidsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
