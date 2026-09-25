defmodule Doggo.Components.VerticalNavNestedTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_vertical_nav_nested()
  end

  describe "vertical_nav_nested/1" do
    test "renders nested list" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:item>item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      assert attribute(html, "div:root > ul", "id") == "nested"
      li = find_one(html, "div:root > ul li")
      assert attribute(li, "aria-labelledby") == nil
      assert text(li) == "item"
      assert Floki.find(html, ".drawer-nav-title") == []
    end

    test "marks current page" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:item current_page>item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      assert attribute(html, "div:root > ul > li", "aria-current") == "page"
    end

    test "labels list with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:title>some title</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      div = find_one(html, "div.vertical-nav-nested-title")
      assert attribute(div, "id") == "nested-title"
      assert text(div) == "some title"

      assert attribute(html, "div:root > ul", "aria-labelledby") ==
               "nested-title"
    end

    test "renders item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_nested id="nested">
          <:item class="is-rad">item</:item>
        </TestComponents.vertical_nav_nested>
        """)

      assert attribute(html, "li", "class") == "is-rad"
    end
  end
end
