defmodule Doggo.Storybook.Label do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:field]

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        slots: ["E-mail"]
      },
      %Variation{
        id: :required,
        attributes: %{required: true},
        slots: ["E-mail"]
      },
      %Variation{
        id: :visually_hidden,
        attributes: %{visually_hidden: true},
        slots: ["E-mail"]
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, _opts) do
    %{
      attributes: %{id: id},
      slots: ["E-mail"]
    }
  end
end
