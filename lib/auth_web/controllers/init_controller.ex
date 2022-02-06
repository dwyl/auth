defmodule AuthWeb.InitController do
  use AuthWeb, :controller

  @env_required ~w/ADMIN_EMAIL AUTH_API_KEY AUTH_URL ENCRYPTION_KEYS SECRET_KEY_BASE/
  @env_optional ~w/EMAIL_APP_URL GITHUB_CLIENT_ID GITHUB_CLIENT_SECRET GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET/

  def index(conn, _params) do

    init = if Envar.is_set_all?(@env_required) do
      # check_app()
      Auth.Init.main()
    else
      "cannot be run until all required environment variables are set"
    end

    conn
    # |> assign(:env, check_env())
    |> render(:index,
      layout: {AuthWeb.InitView, "init_layout.html"}, 
      env: check_env(@env_required),
      env_optional: check_env(@env_optional),
      init: init,
      api_key_set: api_key_set?()
      )
  end

  defp check_env(keys) do
    Enum.reduce(keys, %{}, fn key, acc ->
      Map.put(acc, key, Envar.is_set?(key))
    end)
  end

  defp api_key_set?() do
    IO.puts("AuthPlug.Token.api_key() #{AuthPlug.Token.api_key()}")
    case AuthPlug.Token.api_key() do
      nil -> 
        IO.puts("AuthPlug.Token.api_key() #{AuthPlug.Token.api_key()}")
        false
        
      key ->
        String.length(key) > 1
    end
  end
end
