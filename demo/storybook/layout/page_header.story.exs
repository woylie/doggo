defmodule Storybook.Components.PageHeader do
  use PhoenixStorybook.Story, :component
  use Doggo.Storybook, module: DemoWeb.CoreComponents, name: :page_header
end
