defmodule Storybook.Components.ToggleButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.toggle_button/1

  def variations do
    [
      %VariationGroup{
        id: :variants,
        variations:
          for variant <- Doggo.variants() do
            %Variation{
              id: variant,
              attributes: %{
                on_click: %JS{},
                variant: variant,
                pressed: false
              },
              slots: ["Mute"]
            }
          end
      },
      %VariationGroup{
        id: :disabled,
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
              attributes: %{
                on_click: %JS{},
                variant: variant,
                pressed: false,
                disabled: true
              },
              slots: ["Mute"]
            }
          end
      },
      %VariationGroup{
        id: :fills,
        variations:
          for fill <- Doggo.fills() do
            %Variation{
              id: fill,
              attributes: %{
                on_click: %JS{},
                fill: fill,
                pressed: false
              },
              slots: ["Mute"]
            }
          end
      },
      %VariationGroup{
        id: :sizes,
        variations:
          for size <- Doggo.sizes() do
            %Variation{
              id: size,
              attributes: %{
                on_click: %JS{},
                size: size,
                pressed: false
              },
              slots: ["Mute"]
            }
          end
      },
      %VariationGroup{
        id: :shapes,
        variations:
          for shape <- [nil | Doggo.shapes()] do
            %Variation{
              id: shape || :default,
              attributes: %{
                on_click: %JS{},
                shape: shape,
                pressed: false
              },
              slots: ["Mute"]
            }
          end
      }
    ]
  end
end
