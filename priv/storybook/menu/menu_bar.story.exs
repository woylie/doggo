defmodule Storybook.Components.MenuBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Main"
        },
        slots: [
          """
          <:item>
            <Doggo.menu_button controls="actions-menu" id="actions-button">
              Actions
            </Doggo.menu_button>

            <Doggo.menu id="actions-menu" labelledby="actions-button" hidden>
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
              <:item>
                <Doggo.menu_item on_click={JS.push("dog-care-tips")}>
                  Dog Care Tips
                </Doggo.menu_item>
              </:item>
            </Doggo.menu>
          </:item>
          <:item role="separator"></:item>
          <:item>
            <Doggo.menu_item on_click={JS.dispatch("myapp:help")}>
              Help
            </Doggo.menu_item>
          </:item>
          """
        ]
      }
    ]
  end
end
