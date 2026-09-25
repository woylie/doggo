defmodule Doggo.Components.MenuItemRadioGroupTest do
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

    build_menu_item_radio_group()
  end

  describe "menu_item_radio_group/1" do
    test "renders menu item radio group" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_radio_group label="Theme">
          <:item on_click={JS.push("dark")}>Dark</:item>
        </TestComponents.menu_item_radio_group>
        """)

      ul = find_one(html, "ul:root")
      assert attribute(ul, "role") == "group"
      assert attribute(ul, "aria-label") == "Theme"

      assert li = find_one(html, "ul > li")
      assert attribute(li, "role") == "none"

      assert button = find_one(li, "button")
      assert attribute(button, "role") == "menuitemradio"
      assert attribute(button, "phx-click")
      assert attribute(button, "aria-checked") == "false"
      assert text(button) == "Dark"
    end

    test "renders checked state with checked" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_radio_group label="Theme">
          <:item on_click={JS.push("dark")} checked>Dark</:item>
        </TestComponents.menu_item_radio_group>
        """)

      button = find_one(html, "ul:root > li > button")
      assert attribute(button, "aria-checked") == "true"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item_radio_group label="Dog actions" data-test="hello">
          <:item on_click={JS.push("dark")}>Dark</:item>
        </TestComponents.menu_item_radio_group>
        """)

      assert attribute(html, ":root", "data-test") == "hello"
    end
  end
end
