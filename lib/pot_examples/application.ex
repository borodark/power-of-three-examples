defmodule ExamplesOfPoT.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Get Cube pool configuration
    cube_pool_opts = Application.get_env(:pot_examples, ExamplesOfPoT.CubePool, [])

    children = [
      ExamplesOfPoTWeb.Telemetry,
      Postgres.Repo,
      {DNSCluster, query: Application.get_env(:pot_examples, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ExamplesOfPoT.PubSub},
      # Start a worker by calling: ExamplesOfPoT.Worker.start_link(arg)
      # {ExamplesOfPoT.Worker, arg},
      # Cube ADBC connection pool
      {ExamplesOfPoT.CubePool, cube_pool_opts},
      # Start to serve requests, typically the last entry
      ExamplesOfPoTWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExamplesOfPoT.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExamplesOfPoTWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
