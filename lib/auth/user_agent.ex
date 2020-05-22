defmodule Auth.UserAgent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo

  schema "user_agents" do
    field :name, :string
  end

  @doc false
  def changeset(user_agent, attrs) do
    user_agent
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def get_or_insert_user_agent(ua) do
    # see https://hexdocs.pm/ecto/constraints-and-upserts.html#upserts
    Repo.insert!(
      %Auth.UserAgent{name: ua},
      on_conflict: [set: [name: ua]],
      conflict_target: :name
    )
  end
end
