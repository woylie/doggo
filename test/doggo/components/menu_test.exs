defmodule Doggo.Components.MenuTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_menu()
  end

  describe "menu/1" do
    test "renders menu" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu id="menu" label="Dog actions">
          <:item>A</:item>
        </TestComponents.menu>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "menu"
      assert attribute(ul, "aria-label") == "Dog actions"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"
      assert text(li) == "A"
    end

    test "renders separator item" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu id="menu" label="Dog actions">
          <:item role="separator">A</:item>
        </TestComponents.menu>
        """)

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "separator"
      assert text(li) == ""
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu id="menu" labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-menu-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu id="menu" label="Dog actions" labelledby="dog-menu-label">
          <:item>A</:item>
        </TestComponents.menu>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.menu id="menu">
          <:item>A</:item>
        </TestComponents.menu>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu id="menu" label="Dog actions" data-test="hello">
          <:item>A</:item>
        </TestComponents.menu>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
