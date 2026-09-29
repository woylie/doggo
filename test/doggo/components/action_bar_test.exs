defmodule Doggo.Components.ActionBarTest do
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

    build_action_bar()
  end

  describe "action_bar/1" do
    test "renders action bar" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.action_bar id="action-bar" label="Dog actions">
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </TestComponents.action_bar>
        """)

      assert attribute(html, "div:root", "class") == "action-bar"
      assert attribute(html, ":root", "role") == "toolbar"
      assert attribute(html, ":root", "aria-label") == "Dog actions"

      button = find_one(html, ":root > button")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-label") == "Edit"
      assert attribute(button, "title") == "Edit"

      assert attribute(button, "phx-click") ==
               "[[\"push\",{\"event\":\"edit\"}]]"

      assert text(button) == "edit-icon"
    end

    test "renders labelledby as aria-labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.action_bar id="action-bar" labelledby="dog-heading">
          <:item label="Edit" on_click={JS.push("edit")}>edit-icon</:item>
        </TestComponents.action_bar>
        """)

      assert attribute(html, ":root", "aria-label") == nil
      assert attribute(html, ":root", "aria-labelledby") == "dog-heading"
    end

    test "raises if both label and labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.action_bar
          id="action-bar"
          label="Dog actions"
          labelledby="dog-heading"
        >
          <:item label="Edit" on_click={JS.push("edit")}>edit-icon</:item>
        </TestComponents.action_bar>
        """)
      end
    end

    test "raises if neither label nor labelledby are set" do
      assert_raise Doggo.InvalidLabelError, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.action_bar id="action-bar">
          <:item label="Edit" on_click={JS.push("edit")}>edit-icon</:item>
        </TestComponents.action_bar>
        """)
      end
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.action_bar id="action-bar" label="Dog actions" data-what="ever">
          <:item label="Edit" on_click={JS.push("edit")}>
            edit-icon
          </:item>
        </TestComponents.action_bar>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end

    test "renders nothing without items" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.action_bar id="action-bar" label="Dog actions">
          <:item :for={_ <- []} label="Edit" on_click={JS.push("edit")}>edit</:item>
          <:item :for={_ <- []} label="Move" on_click={JS.push("move")}>move</:item>
          <:item :for={_ <- []} label="Archive" on_click={JS.push("archive")}>
            archive
          </:item>
        </TestComponents.action_bar>
        """)

      assert html == []
    end

    test "raises for blank label" do
      assert_raise ArgumentError, ~r/blank label for/, fn ->
        assigns = %{}

        parse_heex(~H"""
        <TestComponents.action_bar id="action-bar" label="Dog actions">
          <:item label="" on_click={JS.push("edit")}>edit-icon</:item>
        </TestComponents.action_bar>
        """)
      end
    end
  end
end
