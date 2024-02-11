defmodule Storybook.Components.MenuItemRadioGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu_item_radio_group/1

  def template do
    """
    <Doggo.menu label="Actions">
      <:item>
        <.psb-variation/>
      </:item>
    </Doggo.menu>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Theme",
          on_click: Phoenix.LiveView.JS.dispatch("myapp:toggle-word-wrap")
        },
        slots: [
          """
          <:item on_click={JS.dispatch("switch-theme-light")}>Light</:item>
          """,
          """
          <:item on_click={JS.dispatch("switch-theme-dark")}>Dark</:item>
          """
        ]
      }
    ]
  end
end
