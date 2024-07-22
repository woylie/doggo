defmodule Storybook.Components.VerticalNavSection do
  use PhoenixStorybook.Story, :component

  use Doggo.Storybook,
    module: DemoWeb.CoreComponents,
    name: :vertical_nav_section
end
