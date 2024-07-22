defmodule Storybook.Components.Datetime do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :datetime
end
