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
      class_name_fun: &__MODULE__.modifier_class_name/2,
      modifiers: [
        variant: [
          values: ["info", "warning"],
          default: "info"
        ]
      ]
    )

    build_stack(recursive_class: "very-recursive")

    build_tag(
      modifiers: [
        size: [values: ["small", "normal", "large"], default: "normal"]
      ]
    )

    def modifier_class_name(name, value), do: "#{name}-#{value}"
  end

  describe "classes/1" do
    test "returns a list of base, modifier, and nested classes" do
      assert Doggo.classes(TestComponents) == [
               "button",
               "callout",
               "callout-body",
               "callout-icon",
               "callout-message",
               "callout-title",
               "is-large",
               "is-normal",
               "is-primary",
               "is-secondary",
               "is-small",
               "stack",
               "tag",
               "variant-info",
               "variant-warning",
               "very-recursive"
             ]
    end
  end
end
