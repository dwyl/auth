defmodule Auth.Repo.Migrations.AuthProviderLog do
  use Ecto.Migration

  def change do

    alter table(:login_logs) do
      add :auth_provider, :string, default: "email"
    end
  end
end
