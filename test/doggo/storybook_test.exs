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

    accordion(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    action_bar(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    alert(modifiers: [variant: [values: [nil, "yes"], default: nil]])
    button(modifiers: [variant: [values: [nil, "yes"], default: nil]])
  end

  for {name, info} <- TestComponents.__dog_components__() do
    component = Keyword.fetch!(info, :component)

    story_module =
      Module.concat([
        "Story",
        component |> Atom.to_string() |> Macro.camelize()
      ])

    @tag name: name
    @tag info: info
    @tag story_module: story_module
    test "generates storybook modules for #{name}", %{
      name: name,
      info: info,
      story_module: story_module
    } do
      defmodule unquote(story_module) do
        use PhoenixStorybook.Story, :component

        use Doggo.Storybook,
          module: Doggo.StorybookTest.TestComponents,
          name: unquote(name)
      end

      assert story_module.function()
      assert [%Variation{} | _] = story_module.variations()
    end
  end
end
