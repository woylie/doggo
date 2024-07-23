defmodule Doggo.Storybook.FieldDescriptionBuilder do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:input]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{for: "user_name"},
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{for: "user_name"},
      slots: slots(opts)
    }
  end

  defp slots(_opts) do
    [
      """
      only lowercase letters and numbers, max. 30 characters
      """
    ]
  end
end
