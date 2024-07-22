defmodule Storybook.Components.Accordion do
  use PhoenixStorybook.Story, :component

  use Doggo.Storybook,
    module: Elixir.DemoWeb.CoreComponents,
    name: :navbar_items
end
