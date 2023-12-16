defmodule Storybook.Components.Drawer do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.drawer/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          """
          <:brand>
            <Phoenix.Component.link navigate="/">
              Pet Clinic
            </Phoenix.Component.link>
          </:brand>
          """,
          """
          <:top>
            <Doggo.drawer_nav aria-label="Main navigation">
              <:item>
                <Phoenix.Component.link navigate="/dashboard">
                  Dashboard
                </Phoenix.Component.link>
              </:item>
              <:item>
                <Doggo.drawer_nested_nav>
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
                </Doggo.drawer_nested_nav>
              </:item>
            </Doggo.drawer_nav>
            <Doggo.drawer_section>
              <:title>Search</:title>
              <:item><input type="search" placeholder="Search" /></:item>
            </Doggo.drawer_section>
          </:top>
          """,
          """
          <:bottom>
            <Doggo.drawer_nav aria-label="User menu">
              <:item>
                <Phoenix.Component.link navigate="/settings">
                  Settings
                </Phoenix.Component.link>
              </:item>
              <:item>
                <Phoenix.Component.link navigate="/logout">
                  Logout
                </Phoenix.Component.link>
              </:item>
            </Doggo.drawer_nav>
          </:bottom>
          """
        ]
      }
    ]
  end
end
