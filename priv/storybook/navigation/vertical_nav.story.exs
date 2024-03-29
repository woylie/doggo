defmodule Storybook.Components.VerticalNav do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.vertical_nav/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "main-nav",
          label: "Main"
        },
        slots: [
          """
          <:item>
            <Phoenix.Component.link navigate="/dashboard">
              Dashboard
            </Phoenix.Component.link>
          </:item>
          """,
          """
          <:item>
            <Doggo.vertical_nav_nested id="main-nav-content">
              <:title>Content</:title>
              <:item current_page>
                <Phoenix.Component.link navigate="/posts">
                  Posts
                </Phoenix.Component.link>
              </:item>
              <:item>
                <Phoenix.Component.link navigate="/comments">
                  Comments
                </Phoenix.Component.link>
              </:item>
            </Doggo.vertical_nav_nested>
          </:item>
          """
        ]
      }
    ]
  end
end
