defmodule ElixirConfEU.LLM do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """
  alias ElixirConfEU.Chat
  alias ElixirConfEU.Chat.{Conversation, FunctionCall, Message}
  alias Phoenix.PubSub
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias ElixirConfEU.LLM.Function

  def chat(conversation_id, user_input) do
    custom_fn =
      Function.new!(
        __MODULE__,
        :hello,
        "Returns the location of the requested element or item.",
        %{
          type: "object",
          properties: %{
            name: %{
              type: "string",
              description: "The thing whose location is being requested."
            }
          },
          required: ["name"]
        }
      )

    %Conversation{messages: messages, function_calls: function_calls} =
      Chat.get_conversation!(conversation_id)

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

    # create and run the chain
    {:ok, %LLMChain{} = chain} =
      LLMChain.new!(%{
        llm: claude(),
        verbose: true,
        custom_context: %{
          conversation_id: conversation_id
        }
      })
      |> LLMChain.add_tools(custom_fn)
      |> LLMChain.add_messages(convo_items)
      |> LLMChain.add_message(LangChain.Message.new_user!(user_input))
      |> LLMChain.run(mode: :while_needs_response)

    # Create the assistant message in the database
    {:ok, _assistant_message} =
      Chat.create_message(%{
        content: chain.last_message.content,
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

  def hello(args, _context) do
    "The #{args["name"]} is in the drawer!"
  end
end
