defmodule AuthWeb.Router do
  use AuthWeb, :router
  require Ueberauth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AuthWeb do
    pipe_through(:browser)
    get("/register", UserController, :register)
    post("/register", UserController, :register)
    get("/:provider", AuthController, :request)
    post("/identity/callback", AuthController, :identity_callback)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
    delete("/logout", AuthController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", Auth do
  #   pipe_through :api
  # end
end
