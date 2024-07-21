defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/storybook")
  end
end
