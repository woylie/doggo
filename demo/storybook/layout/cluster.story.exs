defmodule Storybook.Components.Cluster do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :cluster
end
