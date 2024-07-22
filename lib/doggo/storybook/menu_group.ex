defmodule Doggo.Storybook.MenuGroup do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu, :menu_item]

  def template(opts) do
    dependent_components = opts[:dependent_components]

    item =
      if item_fun = dependent_components[:menu_item] do
        """
        <.#{item_fun} on_click={JS.push("help")}>Help</.#{item_fun}>
        """
      else
        """
        <:item>
          <p>Please compile the <code>menu_item</code> component to see a complete preview.</p>
        </:item>
        """
      end

    if menu_fun = dependent_components[:menu] do
      """
      <.#{menu_fun} id="actions-menu" label="Main">
        <:item>
          <.psb-variation/>
        </:item>
        <:item role="separator" />
        <:item>
          #{item}
        </:item>
      </.#{menu_fun}>
      """
    else
      """
      <p>Please compile the <code>menu</code> component to see a complete preview.</p>
      <.psb-variation/>
      """
    end
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Dog actions"
        },
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Dog actions"},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    if item_fun = dependent_components[:menu_item] do
      [
        """
        <:item>
          <.#{item_fun} on_click={JS.push("view-dog-profiles")}>
            View Dog Profiles
          </.#{item_fun}>
        </:item>
        <:item>
          <.#{item_fun} on_click={JS.push("add-dog-profile")}>
            Add Dog Profile
          </.#{item_fun}>
        </:item>
        <:item>
          <.#{item_fun} on_click={JS.push("dog-care-tips")}>
            Dog Care Tips
          </.#{item_fun}>
        </:item>
        """
      ]
    else
      [
        """
        <:item>
          <p>Please compile the <code>menu_item</code> component to see a complete preview.</p>
        </:item>
        """
      ]
    end
  end
end
