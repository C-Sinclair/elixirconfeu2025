defmodule ElixirConfEU.LLM do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """
  alias ElixirConfEU.Chat
  alias Phoenix.PubSub
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias LangChain.{Function, Message}

  def chat(conversation_id, user_input) do
    custom_fn =
      Function.new!(%{
        name: "custom",
        description: "Returns the location of the requested element or item.",
        parameters_schema: %{
          type: "object",
          properties: %{
            thing: %{
              type: "string",
              description: "The thing whose location is being requested."
            }
          },
          required: ["thing"]
        },
        function: fn arguments, _context ->
          # Create a function call at the conversation level
          {:ok, _function_call} =
            Chat.create_function_call(%{
              module: "ElixirConfEU.Greeter",
              function: "welcome",
              parameters: arguments,
              result: "Welcome to ElixirConf EU 2025! We're excited to have you here.",
              status: "complete",
              conversation_id: conversation_id
            })

          # broadcast the function call to the client
          PubSub.broadcast(
            ElixirConfEU.PubSub,
            "llm:responses",
            {:llm_response, conversation_id}
          )

          # our context is a pretend item/location location map
          {:ok, "Welcome to ElixirConf EU 2025! We're excited to have you here."}
        end
      })

    # create and run the chain
    {:ok, %LLMChain{} = chain} =
      LLMChain.new!(%{
        llm: ChatAnthropic.new!(%{model: "claude-3-5-sonnet-20240620"}),
        verbose: true
      })
      |> LLMChain.add_tools(custom_fn)
      |> LLMChain.add_message(Message.new_user!(user_input))
      |> LLMChain.run(mode: :while_needs_response)

    # Create the assistant message in the database
    {:ok, assistant_message} =
      Chat.create_message(%{
        content: chain.last_message.content,
        role: "assistant",
        conversation_id: conversation_id
      })

    # Broadcast the message to all subscribers
    PubSub.broadcast(
      ElixirConfEU.PubSub,
      "llm:responses",
      {:llm_response, conversation_id, assistant_message}
    )
  end
end
