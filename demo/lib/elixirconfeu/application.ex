defmodule ElixirConfEU.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirConfEUWeb.Telemetry,
      ElixirConfEU.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:elixirconfeu, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:elixirconfeu, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirConfEU.PubSub},
      {Task.Supervisor, name: ElixirConfEU.TaskSupervisor},
      # Start a worker by calling: ElixirConfEU.Worker.start_link(arg)
      # {ElixirConfEU.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirConfEUWeb.Endpoint,
      # MCP related bits

      # Supervisor.child_spec(
      #   {Hermes.Transport.STDIO,
      #    [
      #      name: ElixirConfEU.PerplexityTransport,
      #      client: ElixirConfEU.PerplexityClient,
      #      command: "bunx",
      #      args: ["server-perplexity-ask"],
      #      env: %{
      #        "PERPLEXITY_API_KEY" => perplexity_api_key()
      #      }
      #    ]},
      #   id: :perplexity_transport
      # ),
      Supervisor.child_spec(
        {Hermes.Transport.STDIO,
         [
           name: ElixirConfEU.FilesystemTransport,
           client: ElixirConfEU.FilesystemClient,
           command: "bunx",
           args: [
             "@modelcontextprotocol/server-filesystem",
             "~/Repos/C-Sinclair/elixirconfeu/demo"
           ]
         ]},
        id: :filesystem_transport
      ),
      # Then start clients that use those transports
      # Supervisor.child_spec(
      #   {Hermes.Client,
      #    [
      #      name: ElixirConfEU.PerplexityClient,
      #      transport: [
      #        layer: Hermes.Transport.STDIO,
      #        name: ElixirConfEU.PerplexityTransport
      #      ],
      #      client_info: %{
      #        "name" => "ElixirConfEU",
      #        "version" => "0.1.0"
      #      },
      #      request_timeout: 120_000,
      #      timeout: 120_000
      #    ]},
      #   id: :perplexity_client
      # ),
      Supervisor.child_spec(
        {Hermes.Client,
         [
           name: ElixirConfEU.FilesystemClient,
           transport: [
             layer: Hermes.Transport.STDIO,
             name: ElixirConfEU.FilesystemTransport
           ],
           client_info: %{
             "name" => "ElixirConfEU",
             "version" => "0.1.0"
           },
           request_timeout: 120_000,
           timeout: 120_000
         ]},
        id: :filesystem_client
      ),
      # Finally start the router
      {ElixirConfEU.MCPRouter,
       [
         clients: [
           # ElixirConfEU.PerplexityClient,
           ElixirConfEU.FilesystemClient
         ]
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirConfEU.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirConfEUWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end

  def perplexity_api_key do
    System.get_env("PERPLEXITY_API_KEY")
  end
end
