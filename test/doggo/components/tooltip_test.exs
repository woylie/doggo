defmodule Doggo.Components.TooltipTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_tooltip()
  end

  describe "tooltip/1" do
    test "passes aria-describedby to the inner block" do
      id = "delete-info"
      expected_id = id <> "-tooltip"
      assigns = %{id: id}

      html =
        parse_heex(~H"""
        <TestComponents.tooltip :let={trigger} id={@id}>
          <button type="button" {trigger}>Delete</button>
          <:tooltip>some details</:tooltip>
        </TestComponents.tooltip>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "id") == id
      assert attribute(span, "aria-describedby") == nil
      assert attribute(span, "tabindex") == nil

      button = find_one(html, "span:root > button")
      assert attribute(button, "aria-describedby") == expected_id
      assert text(button) == "Delete"

      tooltip = find_one(html, "span:root > div[role='tooltip']")
      assert attribute(tooltip, "id") == expected_id
      assert text(tooltip) == "some details"
    end

    test "passes an id that combines with a description of the control" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <p id="delete-hint">Cannot be undone.</p>
        <TestComponents.tooltip :let={trigger} id="delete-info">
          <button
            type="button"
            aria-describedby={"delete-hint " <> trigger["aria-describedby"]}
          >
            Delete
          </button>
          <:tooltip>some details</:tooltip>
        </TestComponents.tooltip>
        """)

      button = find_one(html, "button")

      assert attribute(button, "aria-describedby") ==
               "delete-hint delete-info-tooltip"
    end
  end
end
