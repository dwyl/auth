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

  scope "/auth", AuthWeb do
    pipe_through(:browser)
    get("/register", UserController, :register)
    post("/register", UserController, :register)
    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
    post("/identity/callback", AuthController, :identity_callback)
    delete("/logout", AuthController, :delete)
  end

  scope "/", AuthWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/send-email", SendEmailController, :index)
    post("/send-email", SendEmailController, :send_email)
    resources("/email", EmailController, only: [:index, :create])
    resources("/user", UserController, only: [:index, :create, :new, :show])
  end

  # Other scopes may use custom stacks.
  # scope "/api", Auth do
  #   pipe_through :api
  # end
end
