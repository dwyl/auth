defmodule Auth.Repo.Migrations.ModifyPeopleEmailStringBinary do
  use Ecto.Migration

  def change do
    alter table(:people) do
      remove :email
      add :email, :binary
      add :email_hash, :binary
    end
  end
end
