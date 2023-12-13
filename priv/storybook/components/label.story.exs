defmodule Storybook.Components.Label do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.label/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["E-mail"]
      },
      %Variation{
        id: :required,
        attributes: %{required: true},
        slots: ["E-mail"]
      }
    ]
  end
end
