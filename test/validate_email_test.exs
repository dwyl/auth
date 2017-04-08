defmodule ValidateEmailTest do
  use Auth.ConnCase, async: true
  require ValidateEmail

  test "invalid email address returns {:error, 'Invalid email'}" do
    assert ValidateEmail.validate("invalid") ==
      {:error, "Invalid email"}
  end

  test "Valid email address e.g: username@domain.net returns
    {:ok, ['username@domain.net', 'username', 'domain.net']}" do
    assert ValidateEmail.validate("username@domain.net") ==
      {:ok, ["username@domain.net", "username", "domain.net"]}
  end
end
