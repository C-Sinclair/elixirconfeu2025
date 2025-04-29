defmodule ElixirConfEU.LLM do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """

  require Logger

  alias LangChain.PromptTemplate
  alias LangChain.Utils.ChainResult
  alias ElixirConfEU.Chat
  alias ElixirConfEU.Chat.{Conversation, FunctionCall, Message}
  alias Phoenix.PubSub
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  # alias LangChain.ChatModels.ChatOpenAI
  alias ElixirConfEU.LLM.Function
  alias ElixirConfEU.MCPRouter

  def chat(conversation_id, user_input) do
    Logger.info("[Chat #{conversation_id}] User input: #{user_input}")

    {:ok, %LLMChain{} = chain} =
      LLMChain.new!(%{
        llm: claude(),
        verbose: true,
        custom_context: %{
          conversation_id: conversation_id
        }
      })
      |> add_mcp_tools()
      |> add_macro_functions()
      |> add_convo_items(Chat.get_conversation!(conversation_id))
      |> LLMChain.add_message(LangChain.Message.new_user!(user_input))
      |> LLMChain.run(mode: :while_needs_response)

    # Store the assistant message in the database
    {:ok, _assistant_message} =
      Chat.create_message(%{
        content: ChainResult.to_string!(chain),
        role: "assistant",
        conversation_id: conversation_id
      })

    # Broadcast the message to all subscribers
    PubSub.broadcast(
      ElixirConfEU.PubSub,
      "llm:responses",
      {:llm_response, conversation_id}
    )
  end

  defp claude, do: ChatAnthropic.new!(%{model: "claude-3-5-sonnet-20240620"})

  # defp openai, do: ChatOpenAI.new!(%{model: "gpt-4.1-2025-04-14"})

  defp add_convo_items(chain, %Conversation{messages: messages, function_calls: function_calls}) do
    convo_items =
      messages
      |> Enum.concat(function_calls)
      |> Enum.sort_by(& &1.inserted_at, :asc)
      |> Enum.map(fn
        %Message{
          role: "user",
          content: content
        } ->
          LangChain.Message.new_user!(content)

        %Message{
          role: "assistant",
          content: content
        } ->
          LangChain.Message.new_assistant!(content)

        %FunctionCall{
          result: result,
          module: module,
          function: function
        } ->
          LangChain.Message.new_tool_result!(%{
            name: Function.get_name(module, function),
            content: result
          })
      end)

    chain
    |> LLMChain.add_message(system_message())
    |> LLMChain.add_messages(convo_items)
  end

  defp add_macro_functions(chain) do
    LLMChain.add_tools(
      chain,
      LLMMagic.get_functions()
    )
  end

  @introduction PromptTemplate.from_template!(~s(
    You are a helpful assistant that can help with a variety of tasks.
    You are running in a LiveView app running on localhost:4000
    You are able to make changes to the currently viewed page, this code exists at `./lib/elixirconfeu_web/live/chat_live/show.ex`.
    The root of the filesystem you are aware of is `~/Repos/C-Sinclair/elixirconfeu/demo`.

    When writing Elixir code, ensure that any modules use the following use macro.
    ```elixir
    use LLMMagic
    ```
    Always include an expressive @doc comment for any function you write. Make sure the wording is concise and usable by an LLM when selecting whether to run that function.
    Always make functions arity 2, with the first argument being the `arguments` provided by the LLM and the second being the `context` for the chain. Ignore the context.
    Always return type strings from functions you write.
    Always pick Elixir if there is a choice of programming language.
    Pick random Elixir module names to avoid conflicts.
    Place elixir modules in the `./lib/elixirconfeu/` directory in the typical location which would match the module's name.

    This is a live view app using daisy UI and tailwind. The daisy UI and tailwind config lives at
    `./assets/css/app.css`.
    Changing the theme of DaisyUI can very easily be done the `  name: "night";` on line 2
    of the `@plugin "../vendor/daisyui-theme" {` block.

    Keep responses very concise and to the point.
    ))

  @system_prompt_template PromptTemplate.from_template!(~s(
    <%= @introduction %>
    ))

  defp system_message do
    variables = %{}

    PromptTemplate.format_composed(
      @system_prompt_template,
      %{
        introduction: @introduction
      },
      variables
    )
    |> LangChain.Message.new_system!()
  end

  defp add_mcp_tools(chain) do
    LLMChain.add_tools(chain, mcp_tools() |> Enum.map(&convert_mcp_tool_to_function/1))
  end

  @doc """
  Fetches all available tools from the MCP router and returns them in a format
  suitable for conversion to LangChain Function structs.
  """
  @spec mcp_tools() :: list(map())
  def mcp_tools do
    case MCPRouter.list_tools() do
      {:ok, %Hermes.MCP.Response{result: %{"tools" => tools}}} ->
        Logger.debug("Found MCP tools: #{inspect(tools, pretty: true)}")
        tools

      {:error, error} ->
        Logger.error("Failed to fetch MCP tools: #{inspect(error)}")
        []
    end
  end

  @doc """
  Converts an MCP tool definition into a LangChain Function struct.
  """
  @spec convert_mcp_tool_to_function(map()) :: LangChain.Function.t()
  def convert_mcp_tool_to_function(%{
        "name" => name,
        "description" => description,
        "inputSchema" => parameters
      }) do
    Logger.debug("Converting MCP tool to function: #{name}")

    Function.new_from_mcp!(name, description, parameters, fn arguments, _context ->
      Logger.debug("Calling tool #{name} with arguments: #{inspect(arguments)}")

      result =
        case MCPRouter.call_tool(name, arguments, timeout: 120_000, genserver_timeout: 120_000) do
          {:ok, %Hermes.MCP.Response{result: %{"content" => content}}} when is_list(content) ->
            Logger.debug("Got list content response: #{inspect(content)}")
            result = content |> Enum.map_join("\n", & &1["text"])
            {:ok, result}

          {:ok, %Hermes.MCP.Response{result: %{"content" => content}}}
          when is_binary(content) ->
            Logger.debug("Got binary content response: #{inspect(content)}")
            {:ok, content}

          {:ok, %Hermes.MCP.Response{result: result}} ->
            Logger.debug("Got other result format: #{inspect(result)}")
            {:ok, inspect(result)}

          {:error, error} ->
            Logger.error("Error in tool call: #{inspect(error)}")
            {:error, to_string(error)}

          other ->
            Logger.error("Unexpected response format: #{inspect(other)}")
            {:error, "Unexpected response format"}
        end

      Logger.debug("Tool #{name} returned: #{inspect(result)}")
      result
    end)
  end
end
