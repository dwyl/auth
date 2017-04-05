defmodule Auth.Router do
  use Auth.Web, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", Auth do
    pipe_through :browser
    get "/register", UserController, :register
    post "/register", UserController, :register
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :identity_callback
    delete "/logout", AuthController, :delete
  end

  scope "/", Auth do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/email", EmailController, only: [:index, :create]
  end


  # Other scopes may use custom stacks.
  # scope "/api", Auth do
  #   pipe_through :api
  # end
end
