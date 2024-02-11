defmodule Storybook.Components.MenuGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.menu_group/1

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
