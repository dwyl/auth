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

    get "/", PageController, :index
    get "/auth/github/callback", AuthController, :github_handler
    get "/auth/google/callback", AuthController, :google_handler
  end


  pipeline :auth do
    plug(AuthPlug, %{auth_url: "https://dwylauth.herokuapp.com"})
  end

  scope "/profile", AuthWeb do
    pipe_through :browser
    pipe_through :auth

    get "/", PageController, :admin
    resources "/apikeys", ApikeyController
  end

  # Other scopes may use custom stacks.
  # scope "/api", AuthWeb do
  #   pipe_through :api
  # end
end
