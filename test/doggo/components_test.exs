defmodule Doggo.ComponentsTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Doggo.TestHelpers

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_button()

    build_button(
      name: :button_with_bool_attr,
      modifiers: [full_width: [type: :boolean]]
    )

    build_button(
      name: :button_with_int_attr,
      modifiers: [space: [type: :integer, values: [1, 2, 4]]]
    )

    build_button_link()
  end

  describe "__dog_components__/0" do
    test "returns map of components" do
      assert %{button_link: _} = TestComponents.__dog_components__()
    end
  end

  describe "build_button/1 with boolean modifier" do
    test "omits data attribute without value" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_with_bool_attr>
          Confirm
        </TestComponents.button_with_bool_attr>
        """)

      button = find_one(html, "button:root")
      refute attribute(button, "data-full-width")
    end

    test "omits data attribute for false" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_with_bool_attr full_width={false}>
          Confirm
        </TestComponents.button_with_bool_attr>
        """)

      button = find_one(html, "button:root")
      refute attribute(button, "data-full-width")
    end

    test "renders data attribute for presence-only true" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_with_bool_attr full_width>
          Confirm
        </TestComponents.button_with_bool_attr>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "data-full-width") == "data-full-width"
    end

    test "renders data attribute for explicit true" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_with_bool_attr full_width={true}>
          Confirm
        </TestComponents.button_with_bool_attr>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "data-full-width") == "data-full-width"
    end
  end

  describe "build_button/1 with integer modifier" do
    test "renders value as data attribute" do
      assigns = %{}

      html =
        parse_heex(~H"""
        <TestComponents.button_with_int_attr space={2}>
          Confirm
        </TestComponents.button_with_int_attr>
        """)

      button = find_one(html, "button:root")
      assert attribute(button, "data-space") == "2"
    end
  end
end
