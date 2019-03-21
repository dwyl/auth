defmodule Auth.Email do
  use Bamboo.Phoenix, view: Auth.EmailView

  def send_test_email(to_email_address, subject, message) do
    new_email()
    |> from("nelson@dwyl.io") # also needs to be a validated email
    |> to(to_email_address)
    |> subject(subject)
    |> text_body(message)
  end

  def send_test_email_2(to_email_address, subject, link) do
    new_email()
    # also needs to be a validated email
    |> from("cleo@dwyl.com")
    |> to(to_email_address)
    |> subject(subject)
    |> html_body(
      EEx.eval_file(
        "/Users/Cleo/Documents/dwyl/auth/lib/auth_web/templates/send_email/email.html.eex"
      )
    )
  end
end
