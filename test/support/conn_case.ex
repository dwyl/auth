defmodule AuthWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AuthWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint AuthWeb.Endpoint

      use AuthWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AuthWeb.ConnCase
    end
  end

  setup tags do
    Auth.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in people.

      setup :register_and_log_in_person

  It stores an updated connection and a registered person in the
  test context.
  """
  def register_and_log_in_person(%{conn: conn}) do
    person = Auth.AccountsFixtures.person_fixture()
    %{conn: log_in_person(conn, person), person: person}
  end

  @doc """
  Logs the given `person` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_person(conn, person) do
    token = Auth.Accounts.generate_person_session_token(person)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:person_token, token)
  end
end
