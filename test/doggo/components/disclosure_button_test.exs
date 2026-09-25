defmodule Doggo.Components.DisclosureButtonTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_disclosure_button()
  end

  describe "disclosure_button/1" do
    test "renders disclosure button" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.disclosure_button controls="data-table">
          Data Table
        </TestComponents.disclosure_button>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "type") == "button"
      assert attribute(button, "aria-expanded") == "false"
      assert attribute(button, "aria-controls") == "data-table"
      assert text(button) == "Data Table"
    end
  end
end
