defmodule Doggo.Storybook.MenuItemRadioGroup do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

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
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{
        name => value,
        label: "Theme",
        on_click: Phoenix.LiveView.JS.dispatch("myapp:toggle-word-wrap")
      },
      slots: slots()
    }
  end

  defp slots do
    [
      """
      <:item on_click={JS.dispatch("switch-theme-light")}>Light</:item>
      """,
      """
      <:item on_click={JS.dispatch("switch-theme-dark")}>Dark</:item>
      """
    ]
  end
end
