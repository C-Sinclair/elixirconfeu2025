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
  alias ElixirConfEU.LLM.Function

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

    chain
    |> LLMChain.add_message(system_message())
    |> LLMChain.add_messages(convo_items)
  end

  defp add_macro_functions(chain) do
    LLMChain.add_tools(
      chain,
      ElixirConfEU.LLM.Macros.get_functions()
    )
  end

  @introduction PromptTemplate.from_template!(~s(
    You are a helpful assistant that can help with a variety of tasks.
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
end
