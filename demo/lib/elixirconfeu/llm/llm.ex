defmodule ElixirConfEU.LLM do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """
  alias LangChain.Utils.ChainResult
  alias ElixirConfEU.Chat
  alias ElixirConfEU.Chat.{Conversation, FunctionCall, Message}
  alias Phoenix.PubSub
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias ElixirConfEU.LLM.Function

  def chat(conversation_id, user_input) do
    {:ok, %LLMChain{} = chain} =
      LLMChain.new!(%{
        llm: claude(),
        verbose: true,
        custom_context: %{
          conversation_id: conversation_id
        }
      })
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

    LLMChain.add_messages(chain, convo_items)
  end

  defp add_macro_functions(chain) do
    tools =
      ElixirConfEU.LLM.Macros.get_functions()
      |> IO.inspect()

    LLMChain.add_tools(
      chain,
      tools
    )
  end
end
