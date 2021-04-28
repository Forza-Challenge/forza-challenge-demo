defmodule FCDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FCDemo.Repo,
      # Start the Telemetry supervisor
      FCDemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FCDemo.PubSub},
      # Start the Endpoint (http/https)
      FCDemoWeb.Endpoint,
      # Start a worker by calling: FCDemo.Worker.start_link(arg)
      # {FCDemo.Worker, arg}
      {Finch, name: FCDemo.Finch},
      {FCDemo.GlobalJobsScheduler, superbet_matches_sync_params()},
      {ConCache,
       [
         name: FCDemo.ConCache,
         ttl_check_interval: :timer.seconds(60),
         global_ttl: :timer.seconds(30 * 60)
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FCDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FCDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp superbet_matches_sync_params() do
    %{
      enable: Application.fetch_env!(:forza_challenge_demo, :env) != :test,
      interval: :timer.seconds(5),
      module: FCDemo.SuperbetMatchesSync,
      state: []
    }
  end
end
