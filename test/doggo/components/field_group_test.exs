defmodule Doggo.Components.FieldGroupTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_field_group()
  end

  describe "field_group/1" do
    test "renders field group" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field_group>fields</TestComponents.field_group>
        """)

      div = find_one(html, "div")
      assert attribute(div, "class") == "field-group"
      assert text(div) == "fields"
    end

    test "renders global attributes" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.field_group data-what="ever">fields</TestComponents.field_group>
        """)

      assert attribute(html, "div", "data-what") == "ever"
    end
  end
end
