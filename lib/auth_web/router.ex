defmodule AuthWeb.Router do
  use AuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  scope "/", AuthWeb do
    pipe_through :browser

    get "/", AuthController, :index
    get "/auth/github/callback", AuthController, :github_handler
    get "/auth/google/callback", AuthController, :google_handler
    get "/auth/verify", AuthController, :verify_email
    post "/auth/loginregister", AuthController, :login_register_handler
    # get "/auth/password/new", AuthController, :password_input
    post "/auth/password/create", AuthController, :password_create
    post "/auth/password/verify", AuthController, :password_prompt

    # https://github.com/dwyl/ping
    get "/ping", PingController, :ping
  end

  pipeline :auth do
    plug(AuthPlug, %{auth_url: "https://dwylauth.herokuapp.com"})
  end

  scope "/", AuthWeb do
    pipe_through :browser
    pipe_through :auth

    get "/profile", AuthController, :admin
    resources "/roles", RoleController
    resources "/permissions", PermissionController
    resources "/settings/apikeys", ApikeyController
  end

  # Other scopes may use custom stacks.
  # scope "/api", AuthWeb do
  #   pipe_through :api
  # end
end
