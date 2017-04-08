defmodule Auth.Email do
  use Bamboo.Phoenix, view: Auth.EmailView

  def send_test_email(to_email_address, subject, message) do
    new_email()
    |> from("nelson@dwyl.io") # also needs to be a validated email
    |> to(to_email_address)
    |> subject(subject)
    |> text_body(message)
  end
end
