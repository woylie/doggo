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

    accordion()
  end

  test "generates storybook module" do
    defmodule Story do
      use PhoenixStorybook.Story, :component

      use Doggo.Storybook,
        module: Doggo.StorybookTest.TestComponents,
        name: :accordion
    end

    assert Story.function() == (&Doggo.StorybookTest.TestComponents.accordion/1)
    assert [%Variation{} | _] = Story.variations()
  end
end
