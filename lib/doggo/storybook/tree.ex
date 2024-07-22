defmodule Doggo.Storybook.Tree do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:tree_item]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Dogs"
        },
        slots: slots(opts)
      },
      %Variation{
        id: :with_icons,
        attributes: %{
          label: "Dogs"
        },
        slots: slots_with_icons(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Dogs"},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    if tree_item_component = Map.get(dependent_components, :tree_item) do
      [
        """
        <.#{tree_item_component}>
          Breeds
          <:items>
            <.#{tree_item_component}>Golden Retriever</.#{tree_item_component}>
            <.#{tree_item_component}>Labrador Retriever</.#{tree_item_component}>
          </:items>
        </.#{tree_item_component}>
        <.#{tree_item_component}>
          Characteristics
          <:items>
            <.#{tree_item_component}>Playful</.#{tree_item_component}>
            <.#{tree_item_component}>Loyal</.#{tree_item_component}>
          </:items>
        </.#{tree_item_component}>
        """
      ]
    else
      [
        """
        <p>Please compile the <code>tree_item</code> component for a complete preview.</p>
        """
      ]
    end
  end

  defp slots_with_icons(opts) do
    dependent_components = opts[:dependent_components]

    if tree_item_component = Map.get(dependent_components, :tree_item) do
      folder_icon = icon(:folder, dependent_components)
      paw_icon = icon(:paw, dependent_components)

      [
        """
        <.#{tree_item_component}>
          #{folder_icon} Breeds
          <:items>
            <.#{tree_item_component}>
              #{paw_icon} Golden Retriever
            </.#{tree_item_component}>
            <.#{tree_item_component}>
              #{paw_icon} Labrador Retriever
            </.#{tree_item_component}>
          </:items>
        </.#{tree_item_component}>
        <.#{tree_item_component}>
          #{folder_icon} Characteristics
          <:items>
            <.#{tree_item_component}>
              #{paw_icon} Playful
            </.#{tree_item_component}>
            <.#{tree_item_component}>
              #{paw_icon} Loyal
            </.#{tree_item_component}>
          </:items>
        </.#{tree_item_component}>
        """
      ]
    else
      [
        """
        <p>Please compile the <code>tree_item</code> component for a complete preview.</p>
        """
      ]
    end
  end
end
