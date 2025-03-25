defmodule Elixirconfeu.LLM do
  @moduledoc """
  This module provides a simple interface for interacting with the LLM using Langchain.
  """
  alias ElixirConfEU.Chat
  alias Phoenix.PubSub

  def chat(conversation_id, _user_input) do
    # Process the chat with the LLM (implementation details)
    # This is where you would use Langchain to get a response

    # For the demo, simulate a response
    # Simulate processing time
    Process.sleep(1000)

    # Create the assistant message in the database
    {:ok, assistant_message} =
      Chat.create_message(%{
        content: "This is a response from the LLM module via PubSub.",
        role: "assistant",
        conversation_id: conversation_id
      })

    # Create a function call at the conversation level
    {:ok, _function_call} =
      Chat.create_function_call(%{
        module: "ElixirConfEU.Greeter",
        function: "welcome",
        parameters: %{
          "name" => "ElixirConf EU",
          "year" => 2025
        },
        result: "Welcome to ElixirConf EU 2025! We're excited to have you here.",
        status: "complete",
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
