defmodule Storybook.Components.MenuButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu_button/1

  def template do
    """
    <div>
      <.psb-variation/>
      <ul id="actions-menu" role="menu" aria-labelledby="actions-button" hidden>
        <li role="menuitem">View Dog Profiles</li>
        <li role="menuitem">Add Dog Profile</li>
        <li role="menuitem">Dog Care Tips</li>
      </ul>
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
