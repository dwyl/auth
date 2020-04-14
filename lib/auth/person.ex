defmodule Auth.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo
  alias __MODULE__ # https://stackoverflow.com/a/47501059/1148249

  schema "people" do
    field :email, Fields.EmailEncrypted
    field :email_hash, Fields.EmailHash
    field :familyName, Fields.Encrypted
    field :givenName, Fields.Encrypted
    field :locale, :string
    field :password, :string, virtual: true
    field :password_hash, Fields.Password
    field :picture, :binary
    field :username, :binary
    field :username_hash, Fields.Hash
    field :status, :id
    field :tag, :id
    field :key_id, :integer

    has_many :statuses, Auth.Status
    # has_many :sessions, Auth.Session, on_delete: :delete_all
    timestamps()
  end

  @doc """
  Default attributes validation for Person
  """
  def changeset(person, attrs) do
    # IO.inspect(person, label: "person")
    # IO.inspect(attrs, label: "attrs")
    person
    |> cast(attrs, [
      :username,
      :email,
      :givenName,
      :familyName,
      :password_hash,
      :key_id,
      :locale,
      :picture
    ])
    |> validate_required([
      # :username,
      :email,
      # :givenName,
      # :familyName,
      # :password_hash,
      # :key_id
    ])
    # |> IO.inspect(label: "changeset (before email hash)")
    |> put_email_hash()
  end

  def create_google_person(profile) do
    # IO.inspect(profile, label: "profile")
    # IO.puts(" - - - - - - - - - - - - - - - - - ")
    person = transform_profile_data_to_person(profile)
    # IO.inspect(person, label: "person:60")
    person = %Person{}
    |> google_changeset(person)

    case Person.get_person_by_email(profile.email) do
      nil ->
        Repo.insert!(person)

      person ->
        person
    end

  end

  @doc """
  Changeset used for Google OAuth authentication
  Add email hash and set status verified
  """
  def google_changeset(profile, attrs) do
    profile
    |> cast(attrs, [:email, :givenName, :familyName, :picture, :locale])
    |> validate_required([:email])
    |> put_email_hash()
    |> put_email_status_verified()
  end


  @doc """
  `transform_profile_data_to_person/1` transforms the profile data
  received from invoking `ElixirAuthGoogle.get_user_profile/1`
  into a `person` record that can be inserted into the people table.

  ## Example

    iex> transform_profile_data_to_person(%{
      "email" => "nelson@gmail.com",
      "email_verified" => true,
      "family_name" => "Correia",
      "given_name" => "Nelson",
      "locale" => "en",
      "name" => "Nelson Correia",
      "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7a",
      "sub" => "940732358705212133793"
    })
    %{
      "email" => "nelson@gmail.com",
      "email_verified" => true,
      "family_name" => "Correia",
      "given_name" => "Nelson",
      "locale" => "en",
      "name" => "Nelson Correia",
      "picture" => "https://lh3.googleusercontent.com/a-/AAuE7mApnYb260YC1JY7a",
      "sub" => "940732358705212133793"
      "status" => 1,
      "familyName" => "Correia",
      "givenName" => "Nelson"
    }
  """
  def transform_profile_data_to_person(profile) do
    # IO.inspect(profile, label: "profile transform_profile_data_to_person/1")
    profile
    |> Map.put(:familyName, profile.family_name)
    |> Map.put(:givenName, profile.given_name)
    |> Map.put(:locale, profile.locale)
    |> Map.put(:picture, profile.picture)
  end

  @doc """
  Changeset function used for email/password registration
  Define email hash and password hash
  """
  def changeset_registration(profile, attrs) do
    profile
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:email)
    |> put_email_hash()
    |> put_pass_hash()
  end

  defp put_email_hash(changeset) do
    # IO.inspect(changeset, label: "changeset put_email_hash/1")
    # IO.inspect(changeset.data, label: "changeset.data")
    case changeset do
      %{valid?: true, data: %{email: email}} ->
        put_change(changeset, :email_hash, email)
        # |> IO.inspect(label: "changeset with :email_hash")

      _ ->
        changeset
    end
  end

  defp put_email_status_verified(changeset) do
    status_verified = Auth.Status.upsert_status("verified")

    case changeset do
      %{valid?: true} ->
        put_change(changeset, :status, status_verified.id)

      _ ->
        changeset
    end
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, pass)

      _ ->
        changeset
    end
  end

  @doc """
  `get_person_by_email/1` returns the person based on email address.
  """
  def get_person_by_email(email) do
    # IO.inspect(email, label: "get_person_by_email/1 > email")
    # {:ok, email_hash} = Fields.EmailHash.dump(email)
    # IO.inspect(email_hash, label: "get_person_by_email/1 > email_hash")
    __MODULE__
    |> Repo.get_by(email_hash: email)
    # |> IO.inspect(label: "get_person_by_email/1")
  end
end
