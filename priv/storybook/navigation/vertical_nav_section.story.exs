defmodule Storybook.Components.VerticalNavSection do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.vertical_nav_section/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "site-search"
        },
        slots: [
          """
          <:title>Search</:title>
          """,
          """
          <:item><input type="search" placeholder="Search" /></:item>
          """
        ]
      }
    ]
  end
end
