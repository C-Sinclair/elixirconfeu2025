defmodule ElixirConfEU.Chat do
  @moduledoc """
  The Chat context for handling conversations with an LLM.
  """

  import Ecto.Query, warn: false
  alias ElixirConfEU.Repo

  alias ElixirConfEU.Chat.{Conversation, Message, FunctionCall}

  # Conversation functions

  @doc """
  Returns the list of conversations.
  """
  def list_conversations do
    Repo.all(Conversation)
  end

  @doc """
  Gets a single conversation with its associated messages and function calls.
  """
  def get_conversation!(id) do
    Conversation
    |> Repo.get!(id)
    |> Repo.preload([:messages, :function_calls])
  end

  @doc """
  Creates a conversation.
  """
  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, conversation} ->
        {:ok, Repo.preload(conversation, [:messages, :function_calls])}

      error ->
        error
    end
  end

  @doc """
  Updates a conversation.
  """
  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation.
  """
  def delete_conversation(%Conversation{} = conversation) do
    Repo.delete(conversation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for conversation changes.
  """
  def change_conversation(%Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end

  # Message functions

  @doc """
  Creates a message.
  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists messages for a specific conversation.
  """
  def list_messages(conversation_id) do
    Message
    |> where(conversation_id: ^conversation_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  # Function call functions

  @doc """
  Creates a function call at the conversation level.
  """
  def create_function_call(attrs \\ %{}) do
    %FunctionCall{}
    |> FunctionCall.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists function calls for a specific conversation.
  """
  def list_function_calls(conversation_id) do
    FunctionCall
    |> where(conversation_id: ^conversation_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Updates a function call.
  """
  def update_function_call(%FunctionCall{} = function_call, attrs) do
    function_call
    |> FunctionCall.changeset(attrs)
    |> Repo.update()
  end
end
