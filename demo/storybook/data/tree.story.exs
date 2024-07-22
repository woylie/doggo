defmodule Storybook.Components.Tree do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :tree
end
