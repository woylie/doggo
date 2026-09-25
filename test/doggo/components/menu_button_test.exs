defmodule Doggo.Components.MenuButtonTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_menu_button()
  end

  describe "menu_button/1" do
    test "renders menu button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_button controls="actions-menu" id="actions-button">
          Menu
        </TestComponents.menu_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "id") == "actions-button"
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-haspopup") == "true"
      assert attribute(button, "aria-expanded") == "false"
      assert attribute(button, "aria-controls") == "actions-menu"
      assert attribute(button, "role") == nil
      assert text(button) == "Menu"
    end

    test "renders menuitem role with menuitem" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_button controls="actions-menu" id="actions-button" menuitem>
          Menu
        </TestComponents.menu_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "role") == "menuitem"
    end
  end
end
