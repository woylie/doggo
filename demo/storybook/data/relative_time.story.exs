defmodule Storybook.Components.RelativeTime do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :relative_time
end
