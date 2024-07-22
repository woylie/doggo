defmodule Storybook.Components.MenuItem do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :menu_item
end
