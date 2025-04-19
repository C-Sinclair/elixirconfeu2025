defmodule ElixirConfEU.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :role, :string

    belongs_to :conversation, ElixirConfEU.Chat.Conversation

    timestamps()
  end

  @doc """
  Changeset for messages
  """
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :role, :conversation_id])
    |> validate_required([:content, :role, :conversation_id])
    |> validate_inclusion(:role, ["user", "assistant"])
    |> foreign_key_constraint(:conversation_id)
  end
end
