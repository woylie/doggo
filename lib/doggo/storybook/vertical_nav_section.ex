defmodule Doggo.Storybook.VerticalNavSection do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def template do
    """
    <div style="inline-size: 16rem">
      <.psb-variation/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: slots(opts)
      },
      %Variation{
        id: :multiple_items,
        attributes: %{},
        slots: multiple_item_slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{},
      slots: slots(opts)
    }
  end

  defp slots(_opts) do
    [
      """
      <:title>Search</:title>
      """,
      """
      <:item><input type="search" placeholder="Search" aria-label="Search" /></:item>
      """
    ]
  end

  defp multiple_item_slots(_opts) do
    [
      """
      <:title>Filters</:title>
      """,
      """
      <:item><input type="search" placeholder="Search breeds" aria-label="Search breeds" /></:item>
      """,
      """
      <:item>
        <select aria-label="Size">
          <option>All sizes</option>
          <option>Small</option>
          <option>Medium</option>
          <option>Large</option>
        </select>
      </:item>
      """
    ]
  end
end
