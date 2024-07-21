defmodule Doggo.Storybook.MenuGroup do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <Doggo.menu id="actions-menu" label="Main">
      <:item>
        <.psb-variation/>
      </:item>
      <:item role="separator" />
      <:item>
        <Doggo.menu_item on_click={JS.push("help")}>Help</Doggo.menu_item>
      </:item>
    </Doggo.menu>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Dog actions"
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, label: "Dog actions"},
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
      <:item>
        <Doggo.menu_item on_click={JS.push("dog-care-tips")}>
          Dog Care Tips
        </Doggo.menu_item>
      </:item>
      """
    ]
  end
end
