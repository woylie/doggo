defmodule Storybook.Components.Fallback do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :fallback
end
