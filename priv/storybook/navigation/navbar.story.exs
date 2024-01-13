defmodule Storybook.Components.Navbar do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.navbar/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Main"},
        slots: [
          """
          <:brand>
            <Phoenix.Component.link navigate="/">
              Pet Clinic
            </Phoenix.Component.link>
          </:brand>
          """,
          """
          <Doggo.navbar_items>
            <:item>
              <Phoenix.Component.link navigate="/about">
                About
              </Phoenix.Component.link>
            </:item>
            <:item>
              <Phoenix.Component.link navigate="/services">
                services
              </Phoenix.Component.link>
            </:item>
            <:item>
              <Phoenix.Component.link navigate="/login">
                Log in
              </Phoenix.Component.link>
            </:item>
          </Doggo.navbar_items>
          """
        ]
      },
      %Variation{
        id: :multiple_navigation_sections,
        attributes: %{label: "Main"},
        slots: [
          """
          <:brand>
            <Phoenix.Component.link navigate="/">
              Pet Clinic
            </Phoenix.Component.link>
          </:brand>
          """,
          """
          <Doggo.navbar_items>
            <:item>
              <Phoenix.Component.link navigate="/about">
                About
              </Phoenix.Component.link>
            </:item>
            <:item>
              <Phoenix.Component.link navigate="/services">
                services
              </Phoenix.Component.link>
            </:item>
          </Doggo.navbar_items>
          <Doggo.navbar_items>
            <:item>
              <Doggo.button_link navigate="/login">Log in</Doggo.button_link>
            </:item>
          </Doggo.navbar_items>
          """
        ]
      }
    ]
  end
end
