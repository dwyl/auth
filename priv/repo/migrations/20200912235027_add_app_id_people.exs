defmodule Auth.Repo.Migrations.AddAppIdPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :app_id, references(:apps, on_delete: :delete_all)
    end
  end
end
