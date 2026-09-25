defmodule Doggo.Components.ToolbarTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_toolbar()
  end

  describe "toolbar/1" do
    test "renders toolbar" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar id="toolbar" label="Actions for dog">
          buttons
        </TestComponents.toolbar>
        """)

      assert attribute(html, "div:root", "role") == "toolbar"
      assert attribute(html, ":root", "aria-label") == "Actions for dog"
      assert attribute(html, ":root", "aria-labelledby") == nil
      assert attribute(html, ":root", "aria-orientation") == nil
      assert text(html, ":root") == "buttons"
    end

    test "renders vertical orientation" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar
          id="toolbar"
          label="Actions for dog"
          orientation="vertical"
        >
          buttons
        </TestComponents.toolbar>
        """)

      assert attribute(html, ":root", "aria-orientation") == "vertical"
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar id="toolbar" labelledby="toolbar-heading">
        </TestComponents.toolbar>
        """)

      assert attribute(html, ":root", "aria-label") == nil
      assert attribute(html, ":root", "aria-labelledby") == "toolbar-heading"
    end

    test "renders controls as aria-controls" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar
          id="toolbar"
          label="Actions for dog"
          controls="dog-panel"
        >
        </TestComponents.toolbar>
        """)

      assert attribute(html, ":root", "aria-controls") == "dog-panel"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.toolbar
          id="toolbar"
          label="Dog actions"
          labelledby="dog-toolbar-label"
        >
        </TestComponents.toolbar>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.toolbar id="toolbar"></TestComponents.toolbar>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toolbar id="toolbar" label="Actions for dog" data-test="hello">
        </TestComponents.toolbar>
        """)

      assert attribute(html, "div", "data-test") == "hello"
    end
  end
end
