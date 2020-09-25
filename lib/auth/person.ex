defmodule Auth.Person do
  @moduledoc """
  Defines Person schema and CRUD functions
  """
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query
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
    field :app_id, :integer
    # many_to_many :roles, Auth.Role, join_through: "people_roles"
    # has_many :roles, through: [:people_roles, :role]
    many_to_many :roles, Auth.Role, join_through: Auth.PeopleRoles

    has_many :statuses, Auth.Status
    # has_many :sessions, Auth.Session, on_delete: :delete_all
    timestamps()
  end

  @doc """
  Default attributes validation for Person
  """
  def changeset(person, attrs) do
    # IO.inspect(person, label: "changeset > person")
    # IO.inspect(attrs, label: "changeset > attrs")
    # IO.inspect(roles, label: "changeset > roles")
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
      :status,
      :app_id
    ])
    |> validate_required([:email])
    |> put_email_hash()
    |> put_pass_hash()
  end

  def create_person(person) do
    person =
      %Person{}
      |> changeset(person)
      |> put_email_status_verified()
      # assign default role of "subscriber":
      |> put_assoc(:roles, [Auth.Role.get_role!(6)])

    # other roles can be assigned in the UI

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
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
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
    Map.merge(profile, %{
      username: profile.login,
      givenName: profile.name,
      picture: profile.avatar_url,
      auth_provider: "github"
    })
  end

  def create_github_person(profile) do
    person = upsert_person(transform_github_profile_data_to_person(profile))

    # IO.inspect(person, label: "person:132")
    person
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
    Map.merge(profile, %{
      familyName: profile.family_name,
      givenName: profile.given_name,
      auth_provider: "google"
    })
  end

  def create_google_person(profile) do
    person = upsert_person(transform_google_profile_data_to_person(profile))
    # insert login log entry for the person who just authenticated

    Map.replace!(person, :roles, RBAC.transform_role_list_to_string(person.roles))
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
    put_change(changeset, :email_hash, changeset.changes.email)
  end

  def get_status_verified do
    status = Auth.Status.upsert_status(%{"text" => "verified"})
    status.id
  end

  def put_email_status_verified(changeset) do
    provider = changeset.changes.auth_provider

    if provider == "google" or provider == "github" do
      put_change(changeset, :status, get_status_verified())
    else
      changeset
    end
  end

  def verify_person_by_id(id) do
    person = get_person_by_id(id)
    upsert_person(%{email: person.email, status: get_status_verified()})
  end

  def get_person_by_id(id) do
    __MODULE__
    |> Repo.get_by(id: id)
    |> Repo.preload(:roles)
    |> Repo.preload(:statuses)
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
  def get_person_by_email(email) when not is_nil(email) do
    __MODULE__
    |> Repo.get_by(email_hash: email)
    |> Repo.preload([:statuses, :roles])
  end

  # def get_person_by_email(email) do
  #   IO.inspect(email, label: "email")
  #   __MODULE__
  #   |> Repo.get_by(email_hash: email)
  #   |> Repo.preload([:statuses, :roles])
  # end

  @doc """
  `upsert_person/1` inserts or updates a person record.
  """
  def upsert_person(person) do
    case get_person_by_email(person.email) do
      nil ->
        create_person(person)

      # existing person
      ep ->
        merged = Map.merge(AuthPlug.Helpers.strip_struct_metadata(ep), person)
        {:ok, person} = Repo.update(changeset(%Person{id: ep.id}, merged))
        # ensure that the preloads are returned:
        get_person_by_email(person.email)
    end
  end

  @doc """
  `decrypt_email/1` accepts a `cyphertext` and attempts to Base58.decode
  followed by AES.decrypt it. If decode or decrypt fails, return 0 (zero).
  """
  def decrypt_email(cyphertext) do
    try do
      cyphertext |> Base58.decode() |> Fields.AES.decrypt()
    rescue
      ArgumentError ->
        0
    end
  end

  # @doc """
  # `get_list_of_people/1` retrieves the list of people
  # that a given logged in person can see for all the Apps they have.
  # Used for displaying the table of authenticated people.
  # """
  def get_list_of_people(conn) do
    # IO.inspect(conn.assigns.person)
    apps = Enum.map(Auth.App.list_apps(conn), fn a -> a.id end)
    app_ids = if length(apps) > 0, do: Enum.join(apps, ","), else: "0"

    query = """
    SELECT l.app_id, l.person_id, p.status,
    st.text as status, p."givenName", p.picture,
    l.inserted_at, p.email, l.auth_provider, r.name
    FROM (
      SELECT DISTINCT ON (person_id) *
      FROM logs
      ORDER BY person_id, inserted_at DESC
    ) l
    JOIN people as p on l.person_id = p.id
    LEFT JOIN status as st on p.status = st.id
    LEFT JOIN people_roles as pr on p.id = pr.person_id
    LEFT JOIN roles as r on pr.role_id = r.id
    WHERE l.app_id in (#{app_ids})
    ORDER BY l.inserted_at DESC
    NULLS LAST
    """

    {:ok, result} = Repo.query(query)

    Enum.map(result.rows, fn [aid, pid, sid, s, n, pic, iat, e, aup, role] ->
      %{
        app_id: aid,
        person_id: pid,
        status: s,
        status_id: sid,
        updated_at: NaiveDateTime.truncate(iat, :second),
        givenName: decrypt(n),
        picture: pic,
        email: decrypt(e),
        auth_provider: aup,
        role: role
      }
    end)
  end

  def decrypt(ciphertext) do
    if is_nil(ciphertext) do
      nil
    else
      e = Fields.AES.decrypt(ciphertext)

      if e == :error do
        nil
      else
        e
      end
    end
  end
end
