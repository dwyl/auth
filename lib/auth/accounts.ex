defmodule Auth.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Auth.Repo

  alias Auth.Accounts.{Person, PersonToken, PersonNotifier}

  ## Database getters

  @doc """
  Gets a person by email.

  ## Examples

      iex> get_person_by_email("foo@example.com")
      %Person{}

      iex> get_person_by_email("unknown@example.com")
      nil

  """
  def get_person_by_email(email) when is_binary(email) do
    Repo.get_by(Person, email: email)
  end

  @doc """
  Gets a person by email and password.

  ## Examples

      iex> get_person_by_email_and_password("foo@example.com", "correct_password")
      %Person{}

      iex> get_person_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_person_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    person = Repo.get_by(Person, email: email)
    if Person.valid_password?(person, password), do: person
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.

  ## Examples

      iex> get_person!(123)
      %Person{}

      iex> get_person!(456)
      ** (Ecto.NoResultsError)

  """
  def get_person!(id), do: Repo.get!(Person, id)

  ## Person registration

  @doc """
  Registers a person.

  ## Examples

      iex> register_person(%{field: value})
      {:ok, %Person{}}

      iex> register_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_person(attrs) do
    %Person{}
    |> Person.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.

  ## Examples

      iex> change_person_registration(person)
      %Ecto.Changeset{data: %Person{}}

  """
  def change_person_registration(%Person{} = person, attrs \\ %{}) do
    Person.registration_changeset(person, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the person email.

  ## Examples

      iex> change_person_email(person)
      %Ecto.Changeset{data: %Person{}}

  """
  def change_person_email(person, attrs \\ %{}) do
    Person.email_changeset(person, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_person_email(person, "valid password", %{email: ...})
      {:ok, %Person{}}

      iex> apply_person_email(person, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_person_email(person, password, attrs) do
    person
    |> Person.email_changeset(attrs)
    |> Person.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the person email using the given token.

  If the token matches, the person email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_person_email(person, token) do
    context = "change:#{person.email}"

    with {:ok, query} <- PersonToken.verify_change_email_token_query(token, context),
         %PersonToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(person_email_multi(person, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp person_email_multi(person, email, context) do
    changeset =
      person
      |> Person.email_changeset(%{email: email})
      |> Person.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:person, changeset)
    |> Ecto.Multi.delete_all(:tokens, PersonToken.person_and_contexts_query(person, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given person.

  ## Examples

      iex> deliver_person_update_email_instructions(person, current_email, &url(~p"/people/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_person_update_email_instructions(%Person{} = person, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, person_token} = PersonToken.build_email_token(person, "change:#{current_email}")

    Repo.insert!(person_token)
    PersonNotifier.deliver_update_email_instructions(person, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the person password.

  ## Examples

      iex> change_person_password(person)
      %Ecto.Changeset{data: %Person{}}

  """
  def change_person_password(person, attrs \\ %{}) do
    Person.password_changeset(person, attrs, hash_password: false)
  end

  @doc """
  Updates the person password.

  ## Examples

      iex> update_person_password(person, "valid password", %{password: ...})
      {:ok, %Person{}}

      iex> update_person_password(person, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_person_password(person, password, attrs) do
    changeset =
      person
      |> Person.password_changeset(attrs)
      |> Person.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:person, changeset)
    |> Ecto.Multi.delete_all(:tokens, PersonToken.person_and_contexts_query(person, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{person: person}} -> {:ok, person}
      {:error, :person, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_person_session_token(person) do
    {token, person_token} = PersonToken.build_session_token(person)
    Repo.insert!(person_token)
    token
  end

  @doc """
  Gets the person with the given signed token.
  """
  def get_person_by_session_token(token) do
    {:ok, query} = PersonToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_person_session_token(token) do
    Repo.delete_all(PersonToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given person.

  ## Examples

      iex> deliver_person_confirmation_instructions(person, &url(~p"/people/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_person_confirmation_instructions(confirmed_person, &url(~p"/people/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_person_confirmation_instructions(%Person{} = person, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if person.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, person_token} = PersonToken.build_email_token(person, "confirm")
      Repo.insert!(person_token)
      PersonNotifier.deliver_confirmation_instructions(person, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a person by the given token.

  If the token matches, the person account is marked as confirmed
  and the token is deleted.
  """
  def confirm_person(token) do
    with {:ok, query} <- PersonToken.verify_email_token_query(token, "confirm"),
         %Person{} = person <- Repo.one(query),
         {:ok, %{person: person}} <- Repo.transaction(confirm_person_multi(person)) do
      {:ok, person}
    else
      _ -> :error
    end
  end

  defp confirm_person_multi(person) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:person, Person.confirm_changeset(person))
    |> Ecto.Multi.delete_all(:tokens, PersonToken.person_and_contexts_query(person, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given person.

  ## Examples

      iex> deliver_person_reset_password_instructions(person, &url(~p"/people/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_person_reset_password_instructions(%Person{} = person, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, person_token} = PersonToken.build_email_token(person, "reset_password")
    Repo.insert!(person_token)
    PersonNotifier.deliver_reset_password_instructions(person, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the person by reset password token.

  ## Examples

      iex> get_person_by_reset_password_token("validtoken")
      %Person{}

      iex> get_person_by_reset_password_token("invalidtoken")
      nil

  """
  def get_person_by_reset_password_token(token) do
    with {:ok, query} <- PersonToken.verify_email_token_query(token, "reset_password"),
         %Person{} = person <- Repo.one(query) do
      person
    else
      _ -> nil
    end
  end

  @doc """
  Resets the person password.

  ## Examples

      iex> reset_person_password(person, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Person{}}

      iex> reset_person_password(person, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_person_password(person, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:person, Person.password_changeset(person, attrs))
    |> Ecto.Multi.delete_all(:tokens, PersonToken.person_and_contexts_query(person, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{person: person}} -> {:ok, person}
      {:error, :person, changeset, _} -> {:error, changeset}
    end
  end
end
