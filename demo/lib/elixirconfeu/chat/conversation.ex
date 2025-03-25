defmodule ElixirConfEU.Chat.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :title, :string

    has_many :messages, ElixirConfEU.Chat.Message
    has_many :function_calls, ElixirConfEU.Chat.FunctionCall

    timestamps()
  end

  @doc """
  Changeset for conversations
  """
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
