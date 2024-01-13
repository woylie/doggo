defmodule Storybook.Components.FieldErrors do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.field_errors/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          for: "user_name",
          errors: [
            "should be at most 30 characters",
            "should only contain ASCII characters"
          ]
        }
      }
    ]
  end
end
