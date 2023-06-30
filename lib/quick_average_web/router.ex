defmodule QuickAverageWeb.Router do
  use QuickAverageWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {QuickAverageWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :admins_only do
    plug :admin_basic_auth
  end

  scope "/admin", QuickAverageWeb do
    import Phoenix.LiveDashboard.Router

    pipe_through [:browser, :admins_only]
    live_dashboard("/dashboard", metrics: QuickAverageWeb.Telemetry)
  end

  scope "/about", QuickAverageWeb, assigns: %{about: true} do
    pipe_through(:browser)

    live("/", AboutLive)
  end

  scope "/", QuickAverageWeb do
    pipe_through(:browser)

    live("/", HomeLive)
    live("/:room_id", AverageLive)
  end

  defp admin_basic_auth(conn, _opts) do
    username = Application.fetch_env!(:quick_average, :username)
    password = Application.fetch_env!(:quick_average, :password)
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
