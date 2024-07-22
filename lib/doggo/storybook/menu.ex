defmodule Doggo.Storybook.Menu do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu_item]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "actions-menu",
          label: "Actions"
        },
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, opts) do
    %{
      attributes: %{
        id: id,
        label: "Actions"
      },
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
        <:item role="separator" />
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
