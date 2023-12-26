defmodule Storybook.Components.Tag do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.tag/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["puppy"]
      },
      %Variation{
        id: :pill,
        attributes: %{shape: :pill},
        slots: ["puppy"]
      },
      %VariationGroup{
        id: :variants,
        variations:
          for variant <- [
                :primary,
                :secondary,
                :info,
                :success,
                :warning,
                :danger
              ] do
            %Variation{
              id: variant,
              attributes: %{variant: variant},
              slots: [to_string(variant)]
            }
          end
      },
      %VariationGroup{
        id: :sizes,
        variations:
          for size <- [:small, :normal, :medium, :large] do
            %Variation{
              id: size,
              attributes: %{size: size},
              slots: [to_string(size)]
            }
          end
      }
    ]
  end
end
