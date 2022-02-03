defmodule AuthWeb.StatusController do
  use AuthWeb, :controller

  def index(conn, _params) do
    conn
    # |> assign(:env, check_env())
    |> render(:index,
      layout: {AuthWeb.StatusView, "status_layout.html"}, 
      env: check_env()
      )
  end

  defp check_env() do
    Enum.reduce(Envar.keys(".env_sample"), %{}, fn key, acc ->
      Map.put(acc, key, Envar.is_set?(key))
    end)
  end
end
