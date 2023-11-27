defmodule Storybook.CoreComponents.List do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.app_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          title: "Page title"
        },
        slots: [
          """
          <:navigation label="Toggle menu" on_click={%Phoenix.LiveView.JS{}}>
            <Doggo.icon><Heroicons.bars_3 /></Doggo.icon>
          </:navigation>
          <:action label="Search" on_click={%Phoenix.LiveView.JS{}}>
            <Doggo.icon><Heroicons.magnifying_glass /></Doggo.icon>
          </:action>
          <:action label="Like" on_click={%Phoenix.LiveView.JS{}}>
            <Doggo.icon><Heroicons.heart /></Doggo.icon>
          </:action>
          """
        ]
      }
    ]
  end
end
