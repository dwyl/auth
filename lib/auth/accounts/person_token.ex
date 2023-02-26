defmodule Auth.Accounts.PersonToken do
  use Ecto.Schema
  import Ecto.Query
  alias Auth.Accounts.PersonToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "people_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :person, Auth.Accounts.Person

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual person
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(person) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %PersonToken{token: token, context: "session", person_id: person.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the person found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: person in assoc(token, :person),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: person

    {:ok, query}
  end

  @doc """
  Builds a token and its hash to be delivered to the person's email.

  The non-hashed token is sent to the person email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(person, context) do
    build_hashed_token(person, context, person.email)
  end

  defp build_hashed_token(person, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %PersonToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       person_id: person.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the person found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: person in assoc(token, :person),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == person.email,
            select: person

        {:ok, query}
      # phx.gen.auth boilerplate code not yet covered by tests ...
      # coveralls-ignore-start
      :error ->
        :error
      # coveralls-ignore-stop
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the person found by the token, if any.

  This is used to validate requests to change the person
  email. It is different from `verify_email_token_query/2` precisely because
  `verify_email_token_query/2` validates the email has not changed, which is
  the starting point by this function.

  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity_in_days).
  The context must always start with "change:".
  """
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}
      # phx.gen.auth boilerplate code not yet covered by tests ...
      # coveralls-ignore-start
      :error ->
        :error
      # coveralls-ignore-stop
    end
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def token_and_context_query(token, context) do
    from PersonToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given person for the given contexts.
  """
  def person_and_contexts_query(person, :all) do
    from t in PersonToken, where: t.person_id == ^person.id
  end

  def person_and_contexts_query(person, [_ | _] = contexts) do
    from t in PersonToken, where: t.person_id == ^person.id and t.context in ^contexts
  end
end
