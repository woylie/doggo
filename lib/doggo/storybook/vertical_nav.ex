defmodule Doggo.Storybook.VerticalNav do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "main-nav",
          label: "Main"
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{
        name => value,
        id: "dog-modifier-#{name}-#{value}",
        label: "Main"
      },
      slots: slots()
    }
  end

  defp slots do
    [
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
  end
end
