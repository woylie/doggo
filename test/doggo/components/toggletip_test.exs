defmodule Doggo.Components.ToggletipTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_toggletip()
  end

  describe "toggletip/1" do
    test "renders button that toggles panel" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggletip id="fee-info" label="About the fee">
          The fee covers vaccinations.
        </TestComponents.toggletip>
        """)

      div = find_one(html, "div:root")
      assert attribute(div, "id") == "fee-info"
      assert attribute(div, "class") == "toggletip"
      assert attribute(div, "phx-hook") == "Doggo.Toggletip"

      button = find_one(html, "div:root > button")
      assert attribute(button, "type") == "button"
      assert attribute(button, "class") == "toggletip-button"
      assert attribute(button, "popovertarget") == "fee-info-panel"
      assert attribute(button, "aria-describedby") == nil
      assert text(button, ".toggletip-label") == "About the fee"

      assert attribute(button, ".toggletip-label", "data-visually-hidden") ==
               nil

      panel = find_one(html, "div:root > div")
      assert attribute(panel, "id") == "fee-info-panel"
      assert attribute(panel, "class") == "toggletip-panel"
      assert attribute(panel, "popover") == "auto"
      assert attribute(panel, "role") == nil
      assert text(panel) == "The fee covers vaccinations."

      status = find_one(html, "div:root > span[role='status']")
      assert attribute(status, "class") == "toggletip-status"
      assert attribute(status, "data-visually-hidden") == "data-visually-hidden"
      assert text(status) == ""
    end

    test "hides icon and label visually with icon" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggletip id="fee-info" label="About the fee">
          <:icon>i</:icon>
          The fee covers vaccinations.
        </TestComponents.toggletip>
        """)

      icon = find_one(html, "button > .toggletip-icon")
      assert attribute(icon, "aria-hidden") == "true"
      assert text(icon) == "i"

      label = find_one(html, "button > .toggletip-label")
      assert attribute(label, "data-visually-hidden") == "data-visually-hidden"
      assert text(label) == "About the fee"
    end

    test "names button with labelledby" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <h2 id="fees">Adoption fee</h2>
        <TestComponents.toggletip id="fee-info" labelledby="fees">
          <:icon>i</:icon>
          The fee covers vaccinations.
        </TestComponents.toggletip>
        """)

      button = find_one(html, "button")
      assert attribute(button, "aria-labelledby") == "fees"
      assert Floki.find(button, ".toggletip-label") == []
    end

    test "raises with labelledby and without icon" do
      assigns = %{}

      assert_raise ArgumentError, ~r/missing icon for toggletip/, fn ->
        Phoenix.LiveViewTest.rendered_to_string(~H"""
        <h2 id="fees">Adoption fee</h2>
        <TestComponents.toggletip id="fee-info" labelledby="fees">
          The fee covers vaccinations.
        </TestComponents.toggletip>
        """)
      end
    end

    test "raises with label and labelledby" do
      assigns = %{}

      assert_raise Doggo.InvalidLabelError, fn ->
        Phoenix.LiveViewTest.rendered_to_string(~H"""
        <h2 id="fees">Adoption fee</h2>
        <TestComponents.toggletip id="fee-info" label="About the fee" labelledby="fees">
          <:icon>i</:icon>
          The fee covers vaccinations.
        </TestComponents.toggletip>
        """)
      end
    end

    test "raises with blank label" do
      assigns = %{}

      assert_raise Doggo.InvalidLabelError, fn ->
        Phoenix.LiveViewTest.rendered_to_string(~H"""
        <TestComponents.toggletip id="fee-info" label=" ">
          The fee covers vaccinations.
        </TestComponents.toggletip>
        """)
      end
    end

    test "renders links in panel" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.toggletip id="fee-info" label="About the fee">
          <p>The fee covers vaccinations. <a href="/fees">Fees</a></p>
        </TestComponents.toggletip>
        """)

      assert attribute(html, "div[popover] a", "href") == "/fees"
    end
  end
end
