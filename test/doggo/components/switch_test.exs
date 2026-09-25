defmodule Doggo.Components.SwitchTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_switch()
  end

  describe "switch/1" do
    test "renders unchecked switch with nil checked" do
      assigns = %{checked: nil}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" checked={@checked} />
        """)

      assert attribute(html, "button:root", "aria-checked") == "false"
    end

    test "renders checked switch" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" checked />
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "role") == "switch"
      assert attribute(button, "aria-checked") == "true"

      assert text(button, "span.switch-label") == "Subscribe"

      control = find_one(button, "span.switch-control")
      assert Floki.children(control) == [{"span", [], []}]

      on = find_one(button, "span.switch-state > span.switch-state-on")
      assert attribute(on, "aria-hidden") == "true"
      assert attribute(on, "hidden") == nil
      assert text(on) == "On"

      off = find_one(button, "span.switch-state > span.switch-state-off")
      assert attribute(off, "hidden") == "hidden"
      assert text(off) == "Off"
    end

    test "renders unchecked switch" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" />
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "aria-checked") == "false"

      off = find_one(button, "span.switch-state > span.switch-state-off")
      assert attribute(off, "hidden") == nil
      assert text(off) == "Off"

      on = find_one(button, "span.switch-state > span.switch-state-on")
      assert attribute(on, "hidden") == "hidden"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.switch label="Subscribe" data-test="hello" />
        """)

      assert attribute(html, "button:root", "data-test") == "hello"
    end
  end
end
