defmodule Storybook.Components.MenuItemRadioGroup do
  use PhoenixStorybook.Story, :component

  use Doggo.Storybook,
    module: DemoWeb.CoreComponents,
    name: :menu_item_radio_group
end
