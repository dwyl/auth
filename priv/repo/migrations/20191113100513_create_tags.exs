defmodule App.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :text, :string

      timestamps()
    end
  end
end
