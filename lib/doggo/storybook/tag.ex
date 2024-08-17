defmodule Doggo.Storybook.Tag do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        slots: ["puppy"]
      }
    ]
  end

  def modifier_variation_base(_id, _name, value, _opts) do
    %{
      slots: [value || "nil"]
    }
  end
end
