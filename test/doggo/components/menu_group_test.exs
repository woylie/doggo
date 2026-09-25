defmodule Doggo.Components.MenuGroupTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_menu_group()
  end

  describe "menu_group/1" do
    test "renders menu group" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_group label="Dog actions">
          <:item>A</:item>
        </TestComponents.menu_group>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "group"
      assert attribute(ul, "aria-label") == "Dog actions"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"
      assert text(li) == "A"
    end

    test "renders separator item" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_group label="Dog actions">
          <:item role="separator">A</:item>
        </TestComponents.menu_group>
        """)

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "separator"
      assert text(li) == ""
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_group label="Dog actions" data-test="hello">
          <:item>A</:item>
        </TestComponents.menu_group>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
