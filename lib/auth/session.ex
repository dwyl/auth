defmodule Auth.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :app_id, :id
    field :auth_provider, :string
    field :auth_token, Fields.Encrypted
    field :key_id, :integer
    field :person_id, :id
    field :refresh_token, Fields.Encrypted
    field :user_agent_id, :id
    # belongs_to :person, Auth.Person
    timestamps()
  end

  def changeset(people, attrs) do
    Ecto.build_assoc(people, :sessions)
    |> cast(attrs, [:auth_token, :refresh_token])
    |> validate_required([:app_id, :person_id])
  end

  def basic_changeset(people, _attrs) do
    Ecto.build_assoc(people, :sessions)
  end
end
