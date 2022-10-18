defmodule Auth.Group do
  use Ecto.Schema
  alias Auth.{Repo}
  import Ecto.Changeset
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
    |> cast(attrs, [:name, :desc, :kind])
    |> validate_required([:name, :desc, :kind])
  end

  @doc """
  Creates a `group`.
  """
  def create(attrs) do
    %Group{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
