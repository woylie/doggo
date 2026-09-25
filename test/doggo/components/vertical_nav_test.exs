defmodule Doggo.Components.VerticalNavTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_vertical_nav()
  end

  describe "vertical_nav/1" do
    test "renders vertical nav" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      div = find_one(html, "nav:root")
      assert attribute(div, "id") == "main-nav"
      assert attribute(div, "aria-label") == "Main"
      assert Floki.find(html, ".drawer-nav-title") == []
      assert text(html, ":root > ul > li") == "item"
    end

    test "marks current page" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:item current_page>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, ":root > ul > li", "aria-current") == "page"
    end

    test "renders title" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:title>some title</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert text(html, ":root > div.vertical-nav-title") == "some title"
    end

    test "renders item class" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main">
          <:item class="is-rad">item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, "li", "class") == "is-rad"
    end

    test "renders div with label on list without landmark" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Projects" landmark={false}>
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "id") == "main-nav"
      assert attribute(div, "aria-label") == nil
      assert Floki.find(html, "nav") == []
      assert attribute(html, ":root > ul", "aria-label") == "Projects"
    end

    test "labels list with title without landmark" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" landmark={false}>
          <:title>Projects</:title>
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, ":root", "aria-labelledby") == nil

      assert attribute(html, ":root > ul", "aria-labelledby") ==
               "main-nav-title"

      assert attribute(html, "#main-nav-title", "class") == "vertical-nav-title"
    end

    test "renders without label without landmark" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" landmark={false}>
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, ":root > ul", "aria-label") == nil
      assert attribute(html, ":root > ul", "aria-labelledby") == nil
    end

    test "raises without label" do
      assigns = %{}

      assert_raise Doggo.InvalidLabelError, fn ->
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav">
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.vertical_nav id="main-nav" label="Main" data-test="hello">
          <:item>item</:item>
        </TestComponents.vertical_nav>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
