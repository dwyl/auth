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
    field :desc, :binary
    field :end, :naive_datetime
    field :name, :binary
    field :url, :binary
    field :person_id, :id
    field :status, :id
    # field :apikey_id, :id
    has_many :apikeys, Auth.Apikey

    timestamps()
  end

  @doc false
  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name, :desc, :url, :end, :person_id, :status])
    |> validate_required([:name, :url])
  end

  @doc """
  Returns the list of apps.

  ## Examples

      iex> list_apps()
      [%App{}, ...]

  """
  def list_apps do
    App
    |> where([a], a.status != 6)
    |> Repo.all()

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
  def get_app!(id) do
    # IO.inspect(id, label: "get_app!/1 id:60")
    # Repo.get!(App, id, where: :status != 6)
    # Repo.get!(App, id, where: :status not in [6])
    # |> Repo.preload(:apikeys)
    # |> IO.inspect(label: "get_app!:63")
    App
    |> where([a], a.id == ^id and a.status != 6)
    # |> select([:id, :name, :url, :desc])
    |> Repo.one()
    |> Repo.preload(:apikeys)
    # |> IO.inspect(label: "app:69")

  end

  @doc """
  Creates a app.

  ## Examples

      iex> create_app(%{field: value})
      {:ok, %App{}}

      iex> create_app(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_app(attrs \\ %{}) do
    # IO.inspect(attrs, label: "attrs:87")
    # attrs = Map.merge(attrs, %{status: 3}) # active
    case %App{} |> App.changeset(attrs) |> Repo.insert() do
      {:ok, app} ->
        # Create API Key for App https://github.com/dwyl/auth/issues/97
        AuthWeb.ApikeyController.make_apikey(%{"app" => app}, app.person_id)
        |> Auth.Apikey.create_apikey()

        # return the App with the API Key preloaded:
        {:ok, get_app!(app.id)}

      {:error, err} ->
        {:error, err}
    end
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
    # IO.inspect(app, label: "app:131")
    # Repo.delete(app)
    # |> IO.inspect(label: "delete")
    update_app(app, %{status: 6})
    # |> IO.inspect(label: "delete:135")
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
