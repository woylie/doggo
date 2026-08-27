defmodule DoggoTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

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

  describe "show_modal/2" do
    test "focuses the dialog container, not only its content" do
      assert %Phoenix.LiveView.JS{ops: ops} = Doggo.show_modal("pet-modal")

      assert Enum.any?(ops, fn
               ["focus_first", %{to: "#pet-modal-container"}] -> true
               _ -> false
             end)
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
