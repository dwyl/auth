defmodule Auth.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:status) do
      add :text, :string

      timestamps()
    end
  end
end
