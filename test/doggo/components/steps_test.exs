defmodule Doggo.Components.StepsTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_steps()
  end

  describe "steps/1" do
    test "renders steps without links" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0} label="Order process">
          <:step>Customer Information</:step>
          <:step>Plan</:step>
          <:step>Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Order process"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "span") == "Add-ons"

      assert attribute(li1, "data-state") == "current"
      assert attribute(li2, "data-state") == "upcoming"
      assert attribute(li3, "data-state") == "upcoming"

      assert attribute(li1, "aria-current") == "step"
      assert attribute(li2, "aria-current") == nil
      assert attribute(li3, "aria-current") == nil
    end

    test "renders other steps as links with on_click" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0} label="Order process">
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Order process"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span") == "Customer Information"
      assert text(li2, "a") == "Plan"
      assert text(li3, "a") == "Add-ons"

      assert attribute(li2, "a", "phx-click") == "to-plan"
      assert attribute(li3, "a", "phx-click") == "to-add-ons"
    end

    test "marks completed and current steps" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={1} label="Order process">
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Order process"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span[data-visually-hidden]") == "Completed:"
      assert text(li1, "a") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "a") == "Add-ons"

      assert attribute(li1, "a", "phx-click") == "to-customer-info"
      assert attribute(li3, "a", "phx-click") == "to-add-ons"

      assert attribute(li1, "data-state") == "completed"
      assert attribute(li2, "data-state") == "current"
      assert attribute(li3, "data-state") == "upcoming"
    end

    test "links only completed steps with linear" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={1} linear label="Order process">
          <:step on_click="to-customer-info">Customer Information</:step>
          <:step on_click="to-plan">Plan</:step>
          <:step on_click="to-add-ons">Add-ons</:step>
        </TestComponents.steps>
        """)

      nav = find_one(html, "nav:root")
      assert attribute(nav, "class") == "steps"
      assert attribute(nav, "aria-label") == "Order process"

      ol = find_one(nav, "ol")
      assert [li1, li2, li3] = Floki.children(ol)

      assert text(li1, "span[data-visually-hidden]") == "Completed:"
      assert text(li1, "a") == "Customer Information"
      assert text(li2, "span") == "Plan"
      assert text(li3, "span") == "Add-ons"

      assert attribute(li1, "a", "phx-click") == "to-customer-info"
    end

    test "renders label as aria-label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0} label="Hops">
          <:step>Customer Information</:step>
        </TestComponents.steps>
        """)

      assert attribute(html, "nav:root", "aria-label") == "Hops"
    end

    test "renders completed label" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps
          current_step={1}
          completed_label="Done: "
          label="Order process"
        >
          <:step>Customer Information</:step>
          <:step>Plan</:step>
        </TestComponents.steps>
        """)

      ol = find_one(html, "nav:root ol")
      assert [li1, _] = Floki.children(ol)
      assert text(li1, "span[data-visually-hidden]") == "Done:"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.steps current_step={0} label="Order process" data-test="hello">
          <:step>Plan</:step>
        </TestComponents.steps>
        """)

      assert attribute(html, "nav:root", "data-test") == "hello"
    end
  end
end
