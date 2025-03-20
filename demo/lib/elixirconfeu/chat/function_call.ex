defmodule ElixirConfEU.Chat.FunctionCall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "function_calls" do
    field :function_name, :string
    field :parameters, :map
    field :result, :string
    field :status, :string

    belongs_to :message, ElixirConfEU.Chat.Message

    timestamps()
  end

  @doc """
  Changeset for function calls
  """
  def changeset(function_call, attrs) do
    function_call
    |> cast(attrs, [:function_name, :parameters, :result, :status, :message_id])
    |> validate_required([:function_name, :parameters, :message_id])
    |> validate_inclusion(:status, ["pending", "complete", "error"])
    |> foreign_key_constraint(:message_id)
  end
end
