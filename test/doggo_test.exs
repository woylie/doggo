defmodule DoggoTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest, only: [rendered_to_string: 1]

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    build_button(
      modifiers: [
        size: [values: ["small", "normal"], default: "normal"],
        variant: [
          values: [
            nil,
            "primary",
            "secondary"
          ],
          default: nil
        ]
      ]
    )

    build_callout(
      modifiers: [
        variant: [
          values: ["info", "warning"],
          default: "info"
        ]
      ]
    )

    build_stack()

    build_tag(
      modifiers: [
        size: [values: ["small", "normal", "large"], default: "normal"]
      ]
    )
  end

  defmodule RenamedComponents do
    @moduledoc """
    A component built under a name of the caller's choosing.
    """

    use Doggo.Components
    use Phoenix.Component

    build_toolbar(name: :app_toolbar)
  end

  describe "ensure_label!/2" do
    test "names the component as the caller built it" do
      assigns = %{}

      error =
        assert_raise Doggo.InvalidLabelError, fn ->
          rendered_to_string(~H"""
          <RenamedComponents.app_toolbar id="t">Content</RenamedComponents.app_toolbar>
          """)
        end

      message = Exception.message(error)
      assert message =~ ".app_toolbar"
      refute message =~ ".toolbar "
    end

    test "raises on a label that is set but blank" do
      assigns = %{}

      assert_raise Doggo.InvalidLabelError, fn ->
        rendered_to_string(~H"""
        <RenamedComponents.app_toolbar id="t" label="  ">
          C
        </RenamedComponents.app_toolbar>
        """)
      end
    end

    test "raises on a labelledby that is set but blank" do
      assigns = %{}

      assert_raise Doggo.InvalidLabelError, fn ->
        rendered_to_string(~H"""
        <RenamedComponents.app_toolbar id="t" labelledby="">
          C
        </RenamedComponents.app_toolbar>
        """)
      end
    end

    test "accepts a blank labelledby next to a real label" do
      assigns = %{}

      assert rendered_to_string(~H"""
             <RenamedComponents.app_toolbar id="t" label="Text" labelledby="">
               C
             </RenamedComponents.app_toolbar>
             """) =~ ~s(aria-label="Text")
    end
  end

  describe "show_modal/2" do
    test "dispatches to the hook, which calls showModal()" do
      assert %Phoenix.LiveView.JS{ops: ops} = Doggo.show_modal("pet-modal")

      assert [["dispatch", %{event: "doggo:open", to: "#pet-modal"}]] = ops
    end
  end

  describe "hide_modal/2" do
    test "dispatches to the hook, which calls close()" do
      assert %Phoenix.LiveView.JS{ops: ops} = Doggo.hide_modal("pet-modal")

      assert [["dispatch", %{event: "doggo:close", to: "#pet-modal"}]] = ops
    end
  end

  describe "classes/1" do
    test "returns a list of base and nested classes and data attributes" do
      assert Doggo.safelist(TestComponents) == [
               "button",
               "callout",
               "callout-body",
               "callout-icon",
               "callout-message",
               "callout-title",
               "data-recursive",
               "data-size",
               "data-variant",
               "stack",
               "tag"
             ]
    end
  end
end
