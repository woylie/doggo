defmodule Doggo.Storybook.VerticalNavSection do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: slots(opts)
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
      <:item><input type="search" placeholder="Search" /></:item>
      """
    ]
  end
end
