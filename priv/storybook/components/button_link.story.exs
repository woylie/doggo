defmodule Storybook.Components.ButtonLink do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.button_link/1

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
      %VariationGroup{
        id: :variants,
        variations: [
          %Variation{
            id: :primary_button,
            attributes: %{variant: :primary},
            slots: ["primary"]
          },
          %Variation{
            id: :secondary_button,
            attributes: %{variant: :secondary},
            slots: ["secondary"]
          },
          %Variation{
            id: :info_button,
            attributes: %{variant: :info},
            slots: ["info"]
          },
          %Variation{
            id: :success_button,
            attributes: %{variant: :success},
            slots: ["success"]
          },
          %Variation{
            id: :warning_button,
            attributes: %{variant: :warning},
            slots: ["warning"]
          },
          %Variation{
            id: :danger_button,
            attributes: %{variant: :danger},
            slots: ["danger"]
          }
        ]
      },
      %VariationGroup{
        id: :fills,
        variations: [
          %Variation{
            id: :solid_button,
            attributes: %{fill: :solid},
            slots: ["solid"]
          },
          %Variation{
            id: :outline_button,
            attributes: %{fill: :outline},
            slots: ["outline"]
          },
          %Variation{
            id: :text_button,
            attributes: %{fill: :text},
            slots: ["text"]
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        variations: [
          %Variation{
            id: :small_button,
            attributes: %{size: :small},
            slots: ["small"]
          },
          %Variation{
            id: :normal_button,
            attributes: %{size: :normal},
            slots: ["normal"]
          },
          %Variation{
            id: :medium_button,
            attributes: %{size: :medium},
            slots: ["medium"]
          },
          %Variation{
            id: :large_button,
            attributes: %{size: :large},
            slots: ["large"]
          }
        ]
      },
      %VariationGroup{
        id: :shapes,
        variations: [
          %Variation{
            id: :default_shape_button,
            attributes: %{shape: nil},
            slots: ["default"]
          },
          %Variation{
            id: :circle_button,
            attributes: %{shape: :circle},
            slots: ["circle"]
          },
          %Variation{
            id: :pill_button,
            attributes: %{shape: :pill},
            slots: ["pill"]
          }
        ]
      }
    ]
  end
end
