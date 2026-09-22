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
            id: :user,
            attributes: %{name: "user"}
          },
          %Variation{
            id: :heart,
            attributes: %{name: "heart"}
          },
          %Variation{
            id: :settings,
            attributes: %{name: "settings"}
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
            }
          },
          %Variation{
            id: :before,
            attributes: %{
              name: "heart",
              text: "text before icon",
              text_position: "before"
            }
          },
          %Variation{
            id: :hidden,
            attributes: %{
              name: "settings",
              text: "text hidden",
              text_position: "hidden"
            }
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
            }
          },
          %Variation{
            id: :before,
            attributes: %{
              name: "heart",
              text: "متن قبل از نماد",
              text_position: "before"
            }
          },
          %Variation{
            id: :hidden,
            attributes: %{
              name: "settings",
              text: "متن مخفی",
              text_position: "hidden"
            }
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
      attributes: %{name: "user"}
    }
  end
end
