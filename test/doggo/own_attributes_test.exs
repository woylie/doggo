defmodule Doggo.OwnAttributesTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers
  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]

  alias Doggo.FixtureComponents

  describe "toggle_button/1" do
    test "raises for an attribute the component sets" do
      assigns = %{}

      assert_raise ArgumentError,
                   ~r/phx-click is set by .toggle_button.*Use the on_click attribute instead/s,
                   fn ->
                     rendered_to_string(~H"""
                     <FixtureComponents.toggle_button on_click="mute" phx-click="other">
                       Mute
                     </FixtureComponents.toggle_button>
                     """)
                   end
    end

    test "passes other attributes through" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <FixtureComponents.toggle_button on_click="mute" data-test="mute">
          Mute
        </FixtureComponents.toggle_button>
        """)

      assert attribute(html, "button", "data-test") == "mute"
    end
  end

  describe "toolbar/1" do
    test "raises for a role the component sets" do
      assigns = %{}

      assert_raise ArgumentError, ~r/role is set by .toolbar/, fn ->
        rendered_to_string(~H"""
        <FixtureComponents.toolbar id="actions" label="Actions" role="group">
          Content
        </FixtureComponents.toolbar>
        """)
      end
    end
  end

  describe "drawer/1" do
    test "renders the role passed to it" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <FixtureComponents.drawer id="nav-drawer" role="navigation">
          <:header>Menu</:header>
          <:main>Links</:main>
        </FixtureComponents.drawer>
        """)

      assert attribute(html, "div:root", "role") == "navigation"
    end
  end

  describe "fallback/1" do
    test "renders the role passed to it" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <FixtureComponents.fallback
          value={nil}
          accessibility_text="not available"
          role="note"
        />
        """)

      assert attribute(html, "span", "role") == "note"
    end
  end
end
