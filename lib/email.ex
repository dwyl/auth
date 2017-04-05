defmodule Auth.Email do
  use Bamboo.Phoenix, view: Auth.EmailView

  def send_test_email(from_email_address, subject, message) do
    new_email()
    |> to("nelson@dwyl.io")
    |> from(from_email_address) # also needs to be a validated email
    |> subject(subject)
    |> text_body(message)
  end
end
