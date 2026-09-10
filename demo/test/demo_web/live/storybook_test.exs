defmodule DemoWeb.StorybookTest do
  use DemoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "every story renders", %{conn: conn} do
    {:ok, _live, html} = live(conn, "/storybook/visual_tests?start=a&end=z")

    assert html =~ "button"
  end
end
