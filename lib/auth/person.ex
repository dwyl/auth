defmodule Auth.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias Auth.Repo
  # https://stackoverflow.com/a/47501059/1148249
  alias __MODULE__

  schema "people" do
    field :auth_provider, :string
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
    person
    |> cast(attrs, [
      :id,
      :username,
      :email,
      :givenName,
      :familyName,
      :password,
      :password_hash,
      :key_id,
      :locale,
      :picture,
      :username,
      :auth_provider,
      :status
    ])
    |> validate_required([:email])
    |> put_email_hash()
    |> put_pass_hash()
  end

  def create_person(person) do
    # IO.inspect(person, label: "create_person:51")
    person =
      %Person{}
      |> changeset(person)
      |> put_email_status_verified()
      # |> IO.inspect(label: "after put_email_status_verified")

    case get_person_by_email(person.changes.email) do
      nil ->
        Repo.insert!(person)

      person ->
        person
    end
  end

  def login_register_changeset(attrs) do
    %Person{}
    |> cast(attrs, [:email])
  end

  def password_new_changeset(attrs) do
    %Person{}
    |> cast(attrs, [:email, :password])
  end

  @doc """
  `transform_github_profile_data_to_person/1` transforms the profile data
  received from invoking `ElixirAuthGithub.github_auth/1`
  into a `person` record that can be inserted into the people table.

  ## Example

    iex> transform_profile_data_to_person(%{
      avatar_url: "https://avatars3.githubusercontent.com/u/194400?v=4",
      email: "alex@gmail.com",
      followers: 2846,
      login: "alex",
      name: "Alex McAwesome",
      type: "User",
      url: "https://api.github.com/users/alex"
    })
    %{
      "email" => "nelson@gmail.com",
      "picture" => "https://avatars3.githubusercontent.com/u/194400?v=4",
      "status" => 1,
      "givenName" => "Alex McAwesome"
    }
  """
  def transform_github_profile_data_to_person(profile) do
    profile
    |> Map.put(:username, profile.login)
    |> Map.put(:givenName, profile.name)
    |> Map.put(:picture, profile.avatar_url)
    |> Map.put(:auth_provider, "github")
  end

  def create_github_person(profile) do
    transform_github_profile_data_to_person(profile) |> upsert_person()
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
  def transform_google_profile_data_to_person(profile) do
    # IO.inspect(profile, label: "profile:145")
    Map.merge(profile, %{
      familyName: profile.family_name,
      givenName: profile.given_name,
      auth_provider: "google"
    })
    # |> IO.inspect(label: "merged")
  end

  def create_google_person(profile) do
    transform_google_profile_data_to_person(profile)
    |> upsert_person()
    # |> IO.inspect(label: "create_person:")
  end

  # @doc """
  # Changeset function used for email registration.
  # """
  # def changeset_registration(attrs) do
  #   %Person{}
  #   |> cast(attrs, [:email])
  #   |> validate_required([:email])
  #   |> unique_constraint(:email)
  #   |> put_email_hash()
  # end

  defp put_email_hash(changeset) do
    IO.inspect(changeset, label: "changeset")
    put_change(changeset, :email_hash, changeset.changes.email)
    # |> IO.inspect(label: "changeset with :email_hash")
  end

  def get_status_verified do
    status = Auth.Status.upsert_status("verified")
    status.id
  end

  def put_email_status_verified(changeset) do
    # IO.inspect(changeset, label: "changeset")
    provider = changeset.changes.auth_provider
    if provider == "google" or provider == "github" do
      put_change(changeset, :status, get_status_verified())
    else
      changeset
    end
  end

  def verify_person_by_id(id) do
    person = get_person_by_id(id)
    %{email: person.email, status: get_status_verified()} |> upsert_person()
  end

  def get_person_by_id(id) do
    __MODULE__
    |> Repo.get_by(id: id)
  end

  defp put_pass_hash(changeset) do
    IO.inspect(changeset, label: "changeset put_pass_hash:205")
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
    __MODULE__
    |> Repo.get_by(email_hash: email)
  end

  @doc """
  `upsert_person/1` inserts or updates a person record.
  """
  def upsert_person(person) do
    IO.inspect(person, label: "person:226")
    case get_person_by_email(person.email) do
      nil ->
        create_person(person)

      ep -> # existing person
        merged = Map.merge(AuthPlug.Helpers.strip_struct_metadata(ep), person)
        {:ok, person} = changeset(%Person{id: ep.id}, merged)
        |> IO.inspect(label: "changeset transformed:234")
        |> Repo.update()

        person # |> IO.inspect(label: "updated person:230")
    end
  end


  @doc """
  `decrypt_email/1` accepts a `cyphertext` and attempts to Base58.decode
  followed by AES.decrypt it. If decode or decrypt fails, return 0 (zero).
  """
  def decrypt_email(cyphertext) do
    try do
      cyphertext |> Base58.decode |> Fields.AES.decrypt()
    rescue
      ArgumentError ->
        # IO.puts("AES.decrypt() unable to decrypt client_id")
        0
    end
  end
end
