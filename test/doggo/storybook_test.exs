defmodule Doggo.StorybookTest do
  use ExUnit.Case
  use Phoenix.Component

  alias PhoenixStorybook.Stories.Variation

  defmodule TestComponents do
    @moduledoc """
    Generates components for tests.
    """

    use Doggo.Components
    use Phoenix.Component

    accordion(modifiers: [variant: [values: [nil, "one", "two"], default: nil]])
    button()
  end

  test "generates storybook module for accordion" do
    defmodule Story.Accordion do
      use PhoenixStorybook.Story, :component

      use Doggo.Storybook,
        module: Doggo.StorybookTest.TestComponents,
        name: :accordion
    end

    assert Story.Accordion.function() ==
             (&Doggo.StorybookTest.TestComponents.accordion/1)

    assert [%Variation{} | _] = Story.Accordion.variations()
  end

  test "generates storybook module for button" do
    defmodule Story.Button do
      use PhoenixStorybook.Story, :component

      use Doggo.Storybook,
        module: Doggo.StorybookTest.TestComponents,
        name: :button
    end

    assert Story.Button.function() ==
             (&Doggo.StorybookTest.TestComponents.button/1)

    assert [%Variation{} | _] = Story.Button.variations()
  end
end
