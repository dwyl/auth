defmodule Auth.Token do
  @moduledoc """
  Token module to create and validate jwt.
  see https://hexdocs.pm/joken/configuration.html#module-approach
  """
  use Joken.Config

  @impl true
  def token_config do
    default_claims(default_exp: 31_537_000 ) # ~ 1 year in seconds
  end

end
