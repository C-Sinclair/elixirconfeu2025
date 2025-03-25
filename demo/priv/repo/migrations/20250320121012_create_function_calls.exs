defmodule ElixirConfEU.Repo.Migrations.CreateFunctionCalls do
  use Ecto.Migration

  def change do
    create table(:function_calls) do
      add :module, :string, null: false
      add :function, :string, null: false
      add :parameters, :map
      add :result, :text
      add :status, :string
      add :conversation_id, references(:conversations, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:function_calls, [:conversation_id])
  end
end
