defmodule Storybook.Components.Fab do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.fab/1

  def slot do
    [
      """
      <Doggo.icon>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="lucide lucide-plus"
        >
          <path d="M5 12h14"/>
          <path d="M12 5v14"/>
        </svg>
      </Doggo.icon>
      """
    ]
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Add item"},
        slots: slot()
      },
      %Variation{
        id: :disabled,
        attributes: %{label: "Add item", disabled: true},
        slots: slot()
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
              attributes: %{label: "Add item", variant: variant},
              slots: slot()
            }
          end
      },
      %VariationGroup{
        id: :sizes,
        variations:
          for size <- [:small, :normal, :medium, :large] do
            %Variation{
              id: size,
              attributes: %{label: "Add item", size: size},
              slots: slot()
            }
          end
      },
      %VariationGroup{
        id: :shapes,
        variations: [
          %Variation{
            id: :no_shape,
            attributes: %{label: "Add item", shape: nil},
            slots: slot()
          },
          %Variation{
            id: :circle_button,
            attributes: %{label: "Add item", shape: :circle},
            slots: slot()
          },
          %Variation{
            id: :pill_button,
            attributes: %{label: "Add item", shape: :pill},
            slots: slot()
          }
        ]
      }
    ]
  end
end
