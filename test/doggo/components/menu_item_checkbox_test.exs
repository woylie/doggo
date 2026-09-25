defmodule Doggo.Components.MenuItemCheckboxTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  alias Phoenix.LiveView.JS

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_menu_item_checkbox()
  end

  describe "menu_item_checkbox/1" do
    test "renders unchecked menu item checkbox" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_checkbox on_click={JS.push("hello")}>
          Action
        </TestComponents.menu_item_checkbox>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "phx-click")
      assert attribute(button, "role") == "menuitemcheckbox"
      assert attribute(button, "aria-checked") == "false"
      assert text(button) == "Action"
    end

    test "renders checked state with checked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_checkbox on_click={JS.push("hello")} checked>
          Action
        </TestComponents.menu_item_checkbox>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "aria-checked") == "true"
    end

    test "renders event name in phx-click with on_click event name" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_checkbox on_click="toggle-wrap">
          Wrap
        </TestComponents.menu_item_checkbox>
        """)

      assert attribute(html, ":root", "phx-click") == "toggle-wrap"
    end
  end
end
