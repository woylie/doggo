defmodule Doggo.Storybook.Menu do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "actions-menu",
          label: "Actions"
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation_base(id, _name, _value) do
    %{
      attributes: %{
        id: id,
        label: "Actions"
      },
      slots: slots()
    }
  end

  defp slots do
    [
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
  end
end
