defmodule Storybook.Components.Badge do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.badge/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["8"]
      },
      %Variation{
        id: :large_count,
        slots: ["+1000"]
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
              slots: ["8"]
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
              slots: ["8"]
            }
          end
      }
    ]
  end
end
