defmodule AuthWeb.Router do
  use AuthWeb, :router

  import AuthWeb.PersonAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AuthWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_person
  end

  # uncomment when needed
  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  scope "/", AuthWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", AuthWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:auth, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AuthWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AuthWeb do
    pipe_through [:browser, :redirect_if_person_is_authenticated]

    get "/people/register", PersonRegistrationController, :new
    post "/people/register", PersonRegistrationController, :create
    get "/people/log_in", PersonSessionController, :new
    post "/people/log_in", PersonSessionController, :create
    get "/people/reset_password", PersonResetPasswordController, :new
    post "/people/reset_password", PersonResetPasswordController, :create
    # get "/people/reset_password/:token", PersonResetPasswordController, :edit
    # put "/people/reset_password/:token", PersonResetPasswordController, :update
  end

  scope "/", AuthWeb do
    pipe_through [:browser, :require_authenticated_person]

    get "/people/settings", PersonSettingsController, :edit
    put "/people/settings", PersonSettingsController, :update
    get "/people/settings/confirm_email/:token", PersonSettingsController, :confirm_email
  end

  scope "/", AuthWeb do
    pipe_through [:browser]

    delete "/people/log_out", PersonSessionController, :delete
    get "/people/confirm", PersonConfirmationController, :new
    post "/people/confirm", PersonConfirmationController, :create
    get "/people/confirm/:token", PersonConfirmationController, :edit
    # post "/people/confirm/:token", PersonConfirmationController, :update
  end
end
