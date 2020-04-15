defmodule Auth.Token do
  @moduledoc """
  Token module to create and validate jwt.
  see https://hexdocs.pm/joken/configuration.html#module-approach
  """
  use Joken.Config

  @impl true
  def token_config do
    # ~ 1 year in seconds
    default_claims(default_exp: 31_537_000)
  end
end
