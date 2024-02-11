defmodule Storybook.Components.Menu do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "actions-menu",
          label: "Actions"
        },
        slots: [
          """
          <:item>
            <Doggo.menu_item on_click={JS.push("view-dog-profiles")}>
              View Dog Profiles
            </Doggo.menu_item>
          </:item>
          <:item>
            <Doggo.menu_item on_click={JS.push("add-dog-profile")}>
              Add Dog Profile
            </Doggo.menu_item>
          </:item>
          <:item role="separator" />
          <:item>
            <Doggo.menu_item on_click={JS.push("dog-care-tips")}>
              Dog Care Tips
            </Doggo.menu_item>
          </:item>
          """
        ]
      }
    ]
  end
end
