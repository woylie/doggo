defmodule Doggo.Storybook.Tag do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["puppy"]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value) do
    %{
      slots: ["puppy"]
    }
  end
end
