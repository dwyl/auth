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
    Repo.all(App)
  end

  # Returning all apps when person_id == 1 (superadmin) means
  #  the superadmin can always see/manage all apps as necessary.
  # Later we could refactor this function to use RBAC.has_role_any/2.
  def list_apps(conn) when is_map(conn) do
    case conn.assigns.person.id == 1 do
      true -> Auth.App.list_apps()
      false -> Auth.App.list_apps(conn.assigns.person.id)
    end
  end

  def list_apps(person_id) do
    App
    |> where([a], a.status != 6 and a.person_id == ^person_id)
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
    App
    |> where([a], a.id == ^id and a.status != 6)
    |> Repo.one()
    |> Repo.preload(:apikeys)
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
    case %App{} |> App.changeset(attrs) |> Repo.insert() do
      {:ok, app} ->
        # Create API Key for App https://github.com/dwyl/auth/issues/97
        Auth.Apikey.create_apikey(app)

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
    # |> IO.inspect(label: "update_app/2:109")
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
    # "soft delete" for autiting purposes:
    update_app(app, %{status: 6})
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
