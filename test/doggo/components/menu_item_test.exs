defmodule Doggo.Components.MenuItemTest do
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

    build_menu_item()
  end

  describe "menu_item/1" do
    test "renders menu item" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item on_click={JS.push("hello")}>
          Action
        </TestComponents.menu_item>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "phx-click")
      assert attribute(button, "role") == "menuitem"
      assert text(button) == "Action"
    end

    test "renders event name in phx-click with on_click event name" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.menu_item on_click="copy">Copy</TestComponents.menu_item>
        """)

      assert attribute(html, "button:root", "phx-click") == "copy"
    end

    test "raises for invalid on_click" do
      assigns = %{on_click: 42}

      assert_raise ArgumentError,
                   ~r/invalid on_click value for \.menu_item/,
                   fn ->
                     parse_heex(~H"""
                     <TestComponents.menu_item on_click={@on_click}>Copy</TestComponents.menu_item>
                     """)
                   end
    end
  end
end
