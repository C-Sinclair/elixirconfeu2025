defmodule ElixirConfEU.Chat.FunctionCall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "function_calls" do
    field :module, :string
    field :function, :string
    field :parameters, :map
    field :result, :string
    field :status, :string

    belongs_to :conversation, ElixirConfEU.Chat.Conversation

    timestamps()
  end

  @doc """
  Changeset for function calls
  """
  def changeset(function_call, attrs) do
    function_call
    |> cast(attrs, [:module, :function, :parameters, :result, :status, :conversation_id])
    |> validate_required([:module, :function, :conversation_id])
    |> foreign_key_constraint(:conversation_id)
    |> validate_inclusion(:status, ["pending", "complete", "error"])
  end
end
