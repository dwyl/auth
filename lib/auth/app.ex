defmodule Auth.App do
  @moduledoc """
  Schema and helper functions for creating/managing Apps.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "apps" do
    field :description, :binary
    field :end, :naive_datetime
    field :name, :binary
    field :url, :binary
    field :person_id, :id
    field :status, :id
    # field :apikey_id, :id
    # has_many :apikeys, Auth.Status

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name, :description, :url, :end])
    |> validate_required([:name, :url])
  end

  @doc """
  Returns the list of apps.

  ## Examples

      iex> list_apps()
      [%App{}, ...]

  """
  def list_apps do
    Repo.all(App)
  end

  @doc """
  Gets a single app.

  Raises `Ecto.NoResultsError` if the App does not exist.

  ## Examples

      iex> get_app!(123)
      %App{}

      iex> get_app!(456)
      ** (Ecto.NoResultsError)

  """
  def get_app!(id), do: Repo.get!(App, id)

  @doc """
  Creates a app.

  ## Examples

      iex> create_app(%{field: value})
      {:ok, %App{}}

      iex> create_app(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_app(attrs \\ %{}) do
    %App{}
    |> App.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a app.

  ## Examples

      iex> update_app(app, %{field: new_value})
      {:ok, %App{}}

      iex> update_app(app, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_app(%App{} = app, attrs) do
    app
    |> App.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a app.

  ## Examples

      iex> delete_app(app)
      {:ok, %App{}}

      iex> delete_app(app)
      {:error, %Ecto.Changeset{}}

  """
  def delete_app(%App{} = app) do
    Repo.delete(app)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking app changes.

  ## Examples

      iex> change_app(app)
      %Ecto.Changeset{data: %App{}}

  """
  def change_app(%App{} = app, attrs \\ %{}) do
    App.changeset(app, attrs)
  end
end
