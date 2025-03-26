defmodule ElixirConfEU.LLM do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """
  alias ElixirConfEU.Chat
  alias Phoenix.PubSub
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias LangChain.Message
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

    # TODO: get the conversation messages and function calls
    # order them by created_at
    # add them to the chain

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
      |> LLMChain.add_message(Message.new_user!(user_input))
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
