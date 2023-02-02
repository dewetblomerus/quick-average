defmodule QuickAverage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      QuickAverageWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: QuickAverage.PubSub},
      # Start Finch
      {Finch, name: QuickAverage.Finch},
      # Start the Endpoint (http/https)
      QuickAverageWeb.Endpoint
      # Start a worker by calling: QuickAverage.Worker.start_link(arg)
      # {QuickAverage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuickAverage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuickAverageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
