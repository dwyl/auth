defmodule AuthWeb.Router do
  @moduledoc """
  Defines Web Application Router pipelines and routes
  """
  use AuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth_optional do
    plug(AuthPlugOptional, %{})
  end

  scope "/", AuthWeb do
    pipe_through :browser
    pipe_through :auth_optional

    get "/", AuthController, :index
    get "/auth/github/callback", AuthController, :github_handler
    get "/auth/google/callback", AuthController, :google_handmixler
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

    get "/people", PeopleController, :index
    get "/people/:person_id", PeopleController, :show
    get "/profile", AuthController, :admin

    get "/roles/grant", RoleController, :grant
    post "/roles/grant", RoleController, :grant
    get "/roles/revoke/:people_roles_id", RoleController, :revoke
    post "/roles/revoke/:people_roles_id", RoleController, :revoke
    resources "/roles", RoleController

    resources "/permissions", PermissionController
    get "/apps/:id/resetapikey", AppController, :resetapikey
    resources "/apps", AppController
    # resources "/settings/apikeys", ApikeyController
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/", AuthWeb do
    pipe_through :api

    get "/approles/:client_id", ApiController, :approles
    get "/personroles/:person_id/:client_id", ApiController, :personroles
  end
end
