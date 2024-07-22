defmodule Storybook.Components.Breadcrumb do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :breadcrumb
end
