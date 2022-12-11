defmodule Auth.Repo.Migrations.AddPersonEmailHashUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:people, [:email_hash])
  end
end
