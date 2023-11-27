defmodule DemoWeb.Router do
  use DemoWeb, :router

  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    storybook_assets()
  end

  scope "/", DemoWeb do
    pipe_through :browser
    live_storybook("/", backend_module: DemoWeb.Storybook)
  end
end
