if Code.ensure_loaded?(PhoenixStorybook.Story) do
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
                label: "text after icon",
                label_position: "after"
              }
            },
            %Variation{
              id: :before,
              attributes: %{
                name: "heart",
                label: "text before icon",
                label_position: "before"
              }
            },
            %Variation{
              id: :hidden,
              attributes: %{
                name: "settings",
                label: "text hidden",
                label_position: "hidden"
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
                label: "متن بعد از نماد",
                label_position: "after"
              }
            },
            %Variation{
              id: :before,
              attributes: %{
                name: "heart",
                label: "متن قبل از نماد",
                label_position: "before"
              }
            },
            %Variation{
              id: :hidden,
              attributes: %{
                name: "settings",
                label: "متن مخفی",
                label_position: "hidden"
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
end
