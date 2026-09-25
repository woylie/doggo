defmodule Doggo.Components.VerticalNavSectionTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_vertical_nav_section()
  end

  describe "vertical_nav_section/1" do
    test "renders section" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer">
          <:item>item</:item>
        </TestComponents.vertical_nav_section>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "class") == "vertical-nav-section"
      assert attribute(div, "id") == "my-drawer"
      assert attribute(div, "role") == nil
      assert attribute(div, "aria-labelledby") == nil
      assert Floki.find(html, ".vertical-nav-section-title") == []
      assert text(html, ":root > div.vertical-nav-section-item") == "item"
    end

    test "labels group with title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer">
          <:title>some title</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav_section>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "role") == "group"
      assert attribute(div, "aria-labelledby") == "my-drawer-title"

      div = find_one(html, "div > .vertical-nav-section-title")
      assert attribute(div, "id") == "my-drawer-title"
      assert text(div) == "some title"
    end

    test "renders item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer">
          <:item class="is-rad">item</:item>
        </TestComponents.vertical_nav_section>
        """)

      assert attribute(html, ":root > div", "class") ==
               "vertical-nav-section-item is-rad"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav_section id="my-drawer" data-test="hello">
          <:item>item</:item>
        </TestComponents.vertical_nav_section>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
