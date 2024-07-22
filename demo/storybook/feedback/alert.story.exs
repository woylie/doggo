defmodule Storybook.Components.Alert do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :alert
end
