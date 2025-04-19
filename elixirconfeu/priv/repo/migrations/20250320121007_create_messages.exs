defmodule ElixirConfEU.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :role, :string
      add :conversation_id, references(:conversations, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:messages, [:conversation_id])
  end
end
