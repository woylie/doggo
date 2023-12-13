defmodule Storybook.Components.AppBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.app_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        description: """
        Note that icons have been omitted from this example,
        since Doggo does not ship with a default icon library.
        """,
        attributes: %{
          title: "Page title"
        },
        slots: [
          """
          <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
            <Doggo.icon>Menu</Doggo.icon>
          </:navigation>
          """,
          """
          <:action label="Search" on_click={JS.push("search")}>
            <Doggo.icon>Search</Doggo.icon>
          </:action>
          """,
          """
          <:action label="Like" on_click={JS.push("like")}>
            <Doggo.icon>Like</Doggo.icon>
          </:action>
          """
        ]
      }
    ]
  end
end
