defmodule ElixirConfEU.MCPRouter do
  @moduledoc """
  A router for managing multiple MCP clients and routing tool calls to the appropriate client.
  This enables a single LangChain to leverage tools from multiple MCP servers.
  """

  use GenServer
  require Logger

  @type t :: GenServer.server()
  @type client_name :: atom()
  @type tool_name :: String.t()

  @max_retries 10
  @retry_delay 1000

  # Client API

  @doc """
  Starts the MCP router with a list of client names.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    clients = Keyword.fetch!(opts, :clients)
    GenServer.start_link(__MODULE__, %{clients: clients}, name: __MODULE__)
  end

  @doc """
  Lists all tools from all managed MCP clients.
  """
  @spec list_tools() :: {:ok, list(map())} | {:error, term()}
  def list_tools do
    GenServer.call(__MODULE__, :list_tools, 10_000)
  end

  @doc """
  Calls a tool on the appropriate MCP client.
  """
  @spec call_tool(tool_name(), map() | nil, keyword()) :: {:ok, term()} | {:error, term()}
  def call_tool(tool_name, arguments \\ nil, opts \\ []) do
    GenServer.call(__MODULE__, {:call_tool, tool_name, arguments, opts}, :infinity)
  end

  # Server Callbacks

  @impl true
  def init(%{clients: clients}) do
    state = %{
      clients: clients,
      tool_to_client_map: %{},
      retry_count: 0
    }

    # Schedule a delayed tool mapping refresh to allow clients to start
    Process.send_after(self(), :refresh_tools, 1000)
    Logger.info("MCPRouter initialized, scheduled tool refresh")

    {:ok, state}
  end

  @impl true
  def handle_call(:list_tools, _from, state) do
    tools =
      state.clients
      |> Enum.reduce([], fn client, acc ->
        case Hermes.Client.list_tools(client) do
          {:ok, %Hermes.MCP.Response{result: %{"tools" => client_tools}}} ->
            acc ++ client_tools

          {:error, error} ->
            Logger.error(
              "Failed to fetch tools from client #{inspect(client)}: #{inspect(error)}"
            )

            acc
        end
      end)

    {:reply, {:ok, %Hermes.MCP.Response{result: %{"tools" => tools}}}, state}
  end

  @impl true
  def handle_call({:call_tool, tool_name, arguments, opts}, _from, state) do
    Logger.debug(
      "Attempting to call tool: #{tool_name} with state: #{inspect(state, pretty: true)}"
    )

    client = Map.get(state.tool_to_client_map, tool_name)

    case client do
      nil ->
        Logger.error("Available tools: #{inspect(state.tool_to_client_map, pretty: true)}")
        {:reply, {:error, "No client found for tool: #{tool_name}"}, state}

      client ->
        Logger.debug("Found client for tool #{tool_name}: #{inspect(client)}")
        result = Hermes.Client.call_tool(client, tool_name, arguments, opts)
        {:reply, result, state}
    end
  end

  @impl true
  def handle_info(:refresh_tools, %{retry_count: retry_count} = state) do
    Logger.info("Running delayed tool refresh (attempt #{retry_count + 1})")
    new_state = refresh_tool_mapping(state, retry_count)
    {:noreply, %{new_state | retry_count: retry_count + 1}}
  end

  # Private functions

  defp refresh_tool_mapping(%{retry_count: retry_count} = state, retry_count) do
    Logger.debug("Refreshing tool mapping for clients: #{inspect(state.clients)}")

    tool_to_client_map =
      state.clients
      |> Enum.reduce(%{}, fn client, acc ->
        case Hermes.Client.list_tools(client) do
          {:ok, %Hermes.MCP.Response{result: %{"tools" => client_tools}}} ->
            Logger.debug(
              "Found tools for #{inspect(client)}: #{inspect(client_tools, pretty: true)}"
            )

            client_tools
            |> Enum.reduce(acc, fn tool, tool_map ->
              tool_name = tool["name"]
              Logger.debug("Mapping tool #{tool_name} to client #{inspect(client)}")
              Map.put(tool_map, tool_name, client)
            end)

          {:error, error} ->
            Logger.error(
              "Failed to fetch tools from client #{inspect(client)}: #{inspect(error)}"
            )

            acc
        end
      end)

    if map_size(tool_to_client_map) == 0 and retry_count < @max_retries do
      Logger.warning(
        "No tools found, retrying in #{@retry_delay}ms (attempt #{retry_count + 1}/#{@max_retries})"
      )

      Process.send_after(self(), :refresh_tools, @retry_delay)
      state
    else
      Logger.debug("Final tool mapping: #{inspect(tool_to_client_map, pretty: true)}")
      %{state | tool_to_client_map: tool_to_client_map}
    end
  end
end
