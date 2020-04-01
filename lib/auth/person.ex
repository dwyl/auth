defmodule Auth.Person do
  use Ecto.Schema
  import Ecto.Changeset

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

    has_many :sessions, App.Ctx.Session, on_delete: :delete_all
    timestamps()
  end

  @doc """
  Default attributes validation for Person
  """
  def changeset(person, attrs) do
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
    |> put_email_hash()
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

  defp put_email_hash(changeset) do
    case changeset do
      %{valid?: true, changes: %{email: email}} ->
        put_change(changeset, :email_hash, email)

      _ ->
        changeset
    end
  end

  defp put_email_status_verified(changeset) do
    status_verified = App.Ctx.get_status_verified()

    case changeset do
      %{valid?: true} ->
        put_change(changeset, :status, status_verified.id)

      _ ->
        changeset
    end
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

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, pass)

      _ ->
        changeset
    end
  end
end
