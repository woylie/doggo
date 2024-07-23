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

    build_tag(
      modifiers: [
        size: [values: ["small", "normal", "large"], default: "normal"]
      ]
    )

    def modifier_class_name(name, value), do: "#{name}-#{value}"
  end

  describe "modifier_classes/1" do
    test "returns a map of modifier classes" do
      assert Doggo.modifier_classes(TestComponents) == [
               "is-large",
               "is-normal",
               "is-primary",
               "is-secondary",
               "is-small",
               "variant-info",
               "variant-warning"
             ]
    end
  end
end
