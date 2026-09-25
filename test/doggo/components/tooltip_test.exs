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
    test "describes focusable trigger with tooltip" do
      id = "text-details"
      expected_id = id <> "-tooltip"
      assigns = %{id: id}

      html =
        parse_heex(~H"""
        <TestComponents.tooltip id={@id}>
          some text
          <:tooltip>some details</:tooltip>
        </TestComponents.tooltip>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "id") == id
      assert attribute(span, "aria-describedby") == nil

      inner_span = find_one(html, "span > span")
      assert attribute(inner_span, "tabindex") == "0"
      assert attribute(inner_span, "aria-describedby") == expected_id
      assert text(inner_span) == "some text"

      tooltip = find_one(html, "span > div[role='tooltip']")
      assert attribute(tooltip, "id") == expected_id
      assert text(tooltip) == "some details"
    end

    test "omits tabindex and aria-describedby with contains_link" do
      id = "text-details"
      expected_id = id <> "-tooltip"

      assigns = %{id: id}

      html =
        parse_heex(~H"""
        <TestComponents.tooltip id={@id} contains_link>
          some link
          <:tooltip>some details</:tooltip>
        </TestComponents.tooltip>
        """)

      span = find_one(html, "span:root")
      assert attribute(span, "data-aria-tooltip") == "data-aria-tooltip"
      assert attribute(span, "aria-describedby") == nil

      inner_span = find_one(html, "span:root > span")
      assert attribute(inner_span, "tabindex") == nil
      assert attribute(inner_span, "aria-describedby") == nil
      assert text(inner_span) == "some link"

      tooltip = find_one(html, "span:root > div[role='tooltip']")
      assert attribute(tooltip, "id") == expected_id
      assert text(tooltip) == "some details"
    end
  end
end
