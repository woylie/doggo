defmodule Doggo.Storybook.Badge do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["8"]
      },
      %Variation{
        id: :large_count,
        slots: ["+1000"]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value) do
    %{
      slots: ["8"]
    }
  end
end
