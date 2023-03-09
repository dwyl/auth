defmodule Auth.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Auth.Accounts` context.
  """

  def unique_person_email, do: "person#{System.unique_integer()}@example.com"
  def valid_person_password, do: "hello world!"

  def valid_person_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_person_email(),
      password: valid_person_password()
    })
  end

  def person_fixture(attrs \\ %{}) do
    {:ok, person} =
      attrs
      |> valid_person_attributes()
      |> Auth.Accounts.register_person()

    person
  end

  def extract_person_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
