defmodule Doggo.Components.SplitPaneTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_split_pane()
  end

  describe "split_pane/1" do
    test "renders split pane with label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          label="Sidebar"
          orientation="horizontal"
          default_size={30}
          min_size={10}
          max_size={90}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)

      assert attribute(html, "div:root", "class") == "split-pane"
      assert attribute(html, ":root", "id") == "sidebar-splitter"
      assert attribute(html, ":root", "data-orientation") == "horizontal"

      div = find_one(html, ":root > :first-child")
      assert attribute(div, "id") == "sidebar-splitter-primary"
      assert text(div) == "One"

      div = find_one(html, ":root > :last-child")
      assert attribute(div, "id") == "sidebar-splitter-secondary"
      assert text(div) == "Two"

      div = find_one(html, ":root > div[role='separator']")
      assert attribute(div, "aria-label") == "Sidebar"
      assert attribute(div, "aria-labelledby") == nil
      assert attribute(div, "aria-controls") == "sidebar-splitter-primary"
      assert attribute(div, "aria-valuenow") == "30"
      assert attribute(div, "aria-valuemin") == "10"
      assert attribute(div, "aria-valuemax") == "90"
    end

    test "clamps default size to range" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          label="Sidebar"
          orientation="horizontal"
          default_size={200}
          min_size={10}
          max_size={90}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)

      div = find_one(html, ":root > div[role='separator']")
      assert attribute(div, "aria-valuenow") == "90"
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          labelledby="sidebar-heading"
          orientation="horizontal"
          default_size={30}
        >
          <:primary>
            <h2 id="sidebar-heading">Sidebar</h2>
          </:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)

      div = find_one(html, "[role='separator']")
      assert attribute(div, "aria-label") == nil
      assert attribute(div, "aria-labelledby") == "sidebar-heading"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          label="Sidebar"
          labelledby="sidebar-heading"
          orientation="horizontal"
          default_size={30}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.split_pane
          id="sidebar-splitter"
          orientation="horizontal"
          default_size={30}
        >
          <:primary>One</:primary>
          <:secondary>Two</:secondary>
        </TestComponents.split_pane>
        """)
      end
    end
  end
end
