defmodule Storybook.Components.MenuButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu_button/1

  def template do
    """
    <div>
      <.psb-variation/>
      <Doggo.menu id="actions-menu" labelledby="actions-button" hidden>
        <:item>Copy</:item>
        <:item>Paste</:item>
        <:item role="separator"></:item>
        <:item>Sort lines</:item>
      </Doggo.menu>
    </div>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "actions-menu",
          id: "actions-button"
        },
        slots: ["Actions"]
      }
    ]
  end
end
