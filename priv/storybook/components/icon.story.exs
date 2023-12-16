defmodule Storybook.Components.Icon do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.icon/1

  def svg do
    """
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
      class="lucide lucide-info"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="10"/>
      <path d="M12 16v-4"/>
      <path d="M12 8h.01"/>
    </svg>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: [svg()]
      },
      %VariationGroup{
        id: :sizes,
        variations: [
          %Variation{
            id: :small,
            attributes: %{size: :small},
            slots: [svg()]
          },
          %Variation{
            id: :normal,
            attributes: %{size: :normal},
            slots: [svg()]
          },
          %Variation{
            id: :medium,
            attributes: %{size: :medium},
            slots: [svg()]
          },
          %Variation{
            id: :large,
            attributes: %{size: :large},
            slots: [svg()]
          }
        ]
      },
      %VariationGroup{
        id: :label,
        variations: [
          %Variation{
            id: :left,
            attributes: %{label: "info", label_placement: :left},
            slots: [svg()]
          },
          %Variation{
            id: :right,
            attributes: %{label: "info", label_placement: :right},
            slots: [svg()]
          },
          %Variation{
            id: :hidden,
            attributes: %{label: "info", label_placement: :hidden},
            slots: [svg()]
          }
        ]
      }
    ]
  end
end
