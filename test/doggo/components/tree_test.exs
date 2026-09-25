defmodule Doggo.Components.TreeTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_tree()
  end

  describe "tree/1" do
    test "renders tree with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree id="tree" label="Dogs">
          items
        </TestComponents.tree>
        """)

      assert attribute(html, "ul:root", "role") == "tree"
      assert attribute(html, ":root", "aria-label") == "Dogs"
      assert text(html, ":root") == "items"
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree id="tree" labelledby="dog-tree-label">
        </TestComponents.tree>
        """)

      assert attribute(html, ":root", "aria-labelledby") == "dog-tree-label"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.tree id="tree" label="Dogs" labelledby="dog-tree-label">
        </TestComponents.tree>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.tree id="tree"></TestComponents.tree>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.tree id="tree" labelledby="rg-label" data-test="hi">
        </TestComponents.tree>
        """)

      assert attribute(html, ":root", "data-test") == "hi"
    end
  end
end
