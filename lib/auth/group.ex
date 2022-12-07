defmodule Auth.Group do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias Auth.{Repo}
  alias __MODULE__

  schema "groups" do
    field :desc, :binary
    field :kind, :integer
    field :name, :binary
    belongs_to :app, Auth.App

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :desc, :kind, :app_id])
    |> validate_required([:name, :desc])
  end

  @doc """
  Creates a `group`.
  """
  def create(attrs) do
    %Group{}
    |> changeset(attrs)
    |> put_assoc(:app, Auth.App.get_app!(attrs.app_id))
    |> Repo.insert()
  end

  def get_group_by_id(id) do
    __MODULE__
    |> Repo.get_by(id: id)
  end
end