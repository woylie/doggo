defmodule Storybook.Components.FieldDescription do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.field_description/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{for: "user_name"},
        slots: [
          """
          <:description>
            only lowercase letters and numbers, max. 30 characters
          </:description>
          """
        ]
      }
    ]
  end
end