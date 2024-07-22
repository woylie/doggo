defmodule Storybook.Components.Navbar do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :navbar
end
