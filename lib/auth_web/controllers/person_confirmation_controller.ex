defmodule AuthWeb.PersonConfirmationController do
  use AuthWeb, :controller

  alias Auth.Accounts

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"person" => %{"email" => email}}) do
    if person = Accounts.get_person_by_email(email) do
      Accounts.deliver_person_confirmation_instructions(
        person,
        &url(~p"/people/confirm/#{&1}")
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: ~p"/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, :edit, token: token)
  end

  # Do not log in the person after confirmation to avoid a
  # leaked token giving the person access to the account.
  # def update(conn, %{"token" => token}) do
  #   case Accounts.confirm_person(token) do
  #     {:ok, _} ->
  #       conn
  #       |> put_flash(:info, "Person confirmed successfully.")
  #       |> redirect(to: ~p"/")

  #     :error ->
  #       # If there is a current person and the account was already confirmed,
  #       # then odds are that the confirmation link was already visited, either
  #       # by some automation or by the person themselves, so we redirect without
  #       # a warning message.
  #       case conn.assigns do
  #         %{current_person: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
  #           redirect(conn, to: ~p"/")

  #         %{} ->
  #           conn
  #           |> put_flash(:error, "Person confirmation link is invalid or it has expired.")
  #           |> redirect(to: ~p"/")
  #       end
  #   end
  # end
end
