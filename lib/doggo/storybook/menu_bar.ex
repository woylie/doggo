defmodule Doggo.Storybook.MenuBar do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Main"
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value) do
    %{
      attributes: %{label: "Main"},
      slots: slots()
    }
  end

  defp slots do
    [
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
  end
end
