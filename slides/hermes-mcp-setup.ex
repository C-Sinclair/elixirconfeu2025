def start(_type, _args) do
  children = [
    # Start the MCP transport
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
    # Start the MCP client using the transport
    {Hermes.Client,
     [
       name: ElixirConfEU.FilesystemClient,
       transport: [
         layer: Hermes.Transport.STDIO,
         name: ElixirConfEU.FilesystemTransport
       ],
       client_info: %{
         "name" => "ElixirConfEU",
         "version" => "1.0.0"
       },
       capabilities: %{
         "roots" => %{"listChanged" => true},
         "sampling" => %{}
       }
     ]}
  ]

  opts = [strategy: :one_for_all, name: ElixirConfEU.Supervisor]
  Supervisor.start_link(children, opts)
end
