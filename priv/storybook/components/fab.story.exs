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
          for variant <- Doggo.variants() do
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
          for size <- Doggo.sizes() do
            %Variation{
              id: size,
              attributes: %{label: "Add item", size: size},
              slots: slot()
            }
          end
      },
      %VariationGroup{
        id: :shapes,
        variations:
          for shape <- [nil | Doggo.shapes()] do
            %Variation{
              id: shape || :default,
              attributes: %{label: "Add item", shape: shape},
              slots: slot()
            }
          end
      }
    ]
  end
end
