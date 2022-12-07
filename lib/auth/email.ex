defmodule Auth.Email do
  @doc """
  `sendemail/1` sends an email using AWS SES.
  see: https://github.com/dwyl/email#sending-email
  params is a map that *must* contain the keys: email, name and template.

  ## Examples

    iex> sendemail(%{"email" => "te@st.co", "name" => "Al", "template" => "hi"})
    %{
     "aud" => "Joken",
     "email" => "te@st.co",
     "exp" => 1616864371,
     "iat" => 1585327371,
     "id" => 33,
     "iss" => "Joken",
     "jti" => "2o03dm2ktf6f1j74es0001e3",
     "name" => "Al",
     "nbf" => 1585327371,
     "status" => "Pending",
     "template" => "hi"
    }
  """
  def sendemail(params) do
    url = System.get_env("EMAIL_APP_URL") <> "/api/send"
    # until further notice use the SECRET_KEY_BASE for sending email:
    secret = System.get_env("SECRET_KEY_BASE")
    jwt = AuthPlug.Token.generate_jwt!(params, secret)
    headers = [Authorization: "#{jwt}"]

    options = [
      ssl: [{:versions, [:"tlsv1.2"]}],
      # github.com/dwyl/auth/issues/48
      timeout: 50_000,
      recv_timeout: 50_000
    ]

    {:ok, response} = HTTPoison.post(url, "_nobody", headers, options)
    Jason.decode!(response.body)

  end
end
