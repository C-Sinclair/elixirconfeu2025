case Hermes.Client.call_tool(
       ElixirConfEU.MCPClient,
       "read_file",
       %{path: _}
     ) do
  {:ok, %Hermes.MCP.Response{result: %{"content" => content}}} ->
    nil
    # => Tool Result 
end
