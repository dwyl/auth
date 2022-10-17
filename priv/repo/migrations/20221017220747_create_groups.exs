defmodule Auth.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :binary
      add :desc, :binary
      add :kind, :integer

      timestamps()
    end
  end
end
