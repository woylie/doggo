defmodule Storybook.Components.MenuItem do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu_item/1

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
          on_click: Phoenix.LiveView.JS.dispatch("myapp:copy")
        },
        slots: ["Copy"]
      }
    ]
  end
end
