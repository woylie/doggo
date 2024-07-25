defmodule Doggo.Storybook.IconSprite do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def variations(_opts) do
    [
      %VariationGroup{
        id: :default,
        variations: [
          %Variation{
            id: :after,
            attributes: %{name: "user"},
            slots: slots()
          },
          %Variation{
            id: :before,
            attributes: %{name: "heart"},
            slots: slots()
          },
          %Variation{
            id: :hidden,
            attributes: %{name: "settings"},
            slots: slots()
          }
        ]
      },
      %VariationGroup{
        id: :text_ltr,
        description: "With text (ltr)",
        variations: [
          %Variation{
            id: :after,
            attributes: %{
              name: "user",
              text: "text after icon",
              text_position: "after"
            },
            slots: slots()
          },
          %Variation{
            id: :before,
            attributes: %{
              name: "heart",
              text: "text before icon",
              text_position: "before"
            },
            slots: slots()
          },
          %Variation{
            id: :hidden,
            attributes: %{
              name: "settings",
              text: "text hidden",
              text_position: "hidden"
            },
            slots: slots()
          }
        ]
      },
      %VariationGroup{
        id: :text_rtl,
        description: "With text (rtl)",
        variations: [
          %Variation{
            id: :after,
            attributes: %{
              name: "user",
              text: "متن بعد از نماد",
              text_position: "after"
            },
            slots: slots()
          },
          %Variation{
            id: :before,
            attributes: %{
              name: "heart",
              text: "متن قبل از نماد",
              text_position: "before"
            },
            slots: slots()
          },
          %Variation{
            id: :hidden,
            attributes: %{
              name: "settings",
              text: "متن مخفی",
              text_position: "hidden"
            },
            slots: slots()
          }
        ],
        template: """
        <div dir="rtl">
          <.psb-variation />
        </div>
        """
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{},
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
