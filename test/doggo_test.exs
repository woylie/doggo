defmodule DoggoTest do
  use ExUnit.Case
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

    def modifier_class_name(name, value), do: "#{name}-#{value}"
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
