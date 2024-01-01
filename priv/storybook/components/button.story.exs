defmodule Storybook.Components.Button do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.button/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["click me"]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          disabled: true
        },
        slots: ["click me"]
      },
      %Variation{
        id: :busy,
        attributes: %{
          "aria-busy": true,
          "aria-label": "Saving..."
        },
        slots: ["click me"]
      },
      %VariationGroup{
        id: :variants,
        variations:
          for variant <- Doggo.variants() do
            %Variation{
              id: variant,
              attributes: %{variant: variant},
              slots: [to_string(variant)]
            }
          end
      },
      %VariationGroup{
        id: :fills,
        variations:
          for fill <- Doggo.fills() do
            %Variation{
              id: fill,
              attributes: %{fill: fill},
              slots: [to_string(fill)]
            }
          end
      },
      %VariationGroup{
        id: :sizes,
        variations:
          for size <- Doggo.sizes() do
            %Variation{
              id: size,
              attributes: %{size: size},
              slots: [to_string(size)]
            }
          end
      },
      %VariationGroup{
        id: :shapes,
        variations:
          for shape <- [nil | Doggo.shapes()] do
            %Variation{
              id: shape || :default,
              attributes: %{shape: shape},
              slots: ["#{shape || :default}"]
            }
          end
      }
    ]
  end
end
