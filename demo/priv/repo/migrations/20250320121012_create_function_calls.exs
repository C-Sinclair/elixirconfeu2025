defmodule ElixirConfEU.Repo.Migrations.CreateFunctionCalls do
  use Ecto.Migration

  def change do
    create table(:function_calls) do
      add :function_name, :string
      add :parameters, :map
      add :result, :text
      add :status, :string
      add :message_id, references(:messages, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:function_calls, [:message_id])
  end
end
