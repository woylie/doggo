defmodule Doggo.Storybook.Icon do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: slots()
      },
      %VariationGroup{
        id: :label,
        variations: [
          %Variation{
            id: :left,
            attributes: %{label: "info", label_placement: :left},
            slots: slots()
          },
          %Variation{
            id: :right,
            attributes: %{label: "info", label_placement: :right},
            slots: slots()
          },
          %Variation{
            id: :hidden,
            attributes: %{label: "info", label_placement: :hidden},
            slots: slots()
          }
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      slots: slots()
    }
  end

  def slots do
    [
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
    ]
  end
end
