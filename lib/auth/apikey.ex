defmodule Auth.Apikey do
  @moduledoc """
  Defines apikeys schema and CRUD functions
  """
  use Ecto.Schema
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "apikeys" do
    field :client_secret, :binary
    field :client_id, :binary
    field :person_id, :id
    field :status, :id
    belongs_to :app, Auth.App

    timestamps()
  end

  @doc """
  `encrypt_encode/1` does exactly what it's name suggests,
  AES Encrypts a string of plaintext and then Base58 encodes it.
  We encode it using Base58 so it's human-friendly (readable).
  """
  def encrypt_encode(plaintext) do
    plaintext |> Fields.AES.encrypt() |> Base58.encode()
  end

  @doc """
  `create_api_key/1` uses the `encrypt_encode/1` to create an API Key
  that is just two strings joined with a forwardslash ("/").
  This allows us to use a *single* environment variable.
  """
  def create_api_key(person_id) do
    encrypt_encode(person_id) <> "/" <> encrypt_encode(person_id)
  end

  @doc """
  `decode_decrypt/1` accepts a `key` and attempts to Base58.decode
  followed by AES.decrypt it. If decode or decrypt fails, return 0 (zero).
  """
  def decode_decrypt(key) do
    try do
      key |> Base58.decode() |> Fields.AES.decrypt() |> String.to_integer()
    rescue
      ArgumentError ->
        0
    end
  end

  def decrypt_api_key(key) do
    key |> String.split("/") |> List.first() |> decode_decrypt()
  end

  def changeset(apikey, attrs) do
    apikey
    |> cast(attrs, [:client_id, :client_secret, :person_id, :status])
    |> put_assoc(:app, Map.get(attrs, "app"))
  end

  def create_apikey(app) do
    attrs = %{
      "client_secret" => encrypt_encode(app.person_id),
      "client_id" => encrypt_encode(app.person_id),
      "person_id" => app.person_id,
      "status" => 3,
      "app" => app
    }

    %Apikey{}
    |> Apikey.changeset(attrs)
    |> Repo.insert()
  end

  def list_apikeys_for_person(person_id) do
    from(
      a in __MODULE__,
      where: a.person_id == ^person_id
    )
    |> Repo.all()
    |> Repo.preload(:app)
  end

  @doc """
  Updates a apikey.

  ## Examples

      iex> update_apikey(apikey, %{field: new_value})
      {:ok, %Apikey{}}

      iex> update_apikey(apikey, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_apikey(%Apikey{} = apikey, attrs) do
    apikey
    |> changeset(attrs)
    |> Repo.update()
  end
end
