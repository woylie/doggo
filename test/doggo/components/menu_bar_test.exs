defmodule Doggo.Components.MenuBarTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_menu_bar()
  end

  describe "menu_bar/1" do
    test "renders menu bar" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar id="menu-bar" label="Dog actions">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "menubar"
      assert attribute(ul, "aria-label") == "Dog actions"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"
      assert text(li) == "A"
    end

    test "renders separator item" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar id="menu-bar" label="Dog actions">
          <:item role="separator">A</:item>
        </TestComponents.menu_bar>
        """)

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "separator"
      assert text(li) == ""
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar id="menu-bar" labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-menu-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu_bar
          id="menu-bar"
          label="Dog actions"
          labelledby="dog-menu-label"
        >
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu_bar id="menu-bar">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_bar id="menu-bar" label="Dog actions" data-test="hello">
          <:item>A</:item>
        </TestComponents.menu_bar>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
