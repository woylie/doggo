defmodule Doggo.Storybook.Switch do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def variations(_opts) do
    [
      %VariationGroup{
        id: :default,
        variations: [
          %Variation{
            id: :on,
            attributes: %{
              label: "Subscribe",
              checked: true,
              phx_click: "toggle-subscription"
            }
          },
          %Variation{
            id: :off,
            attributes: %{
              label: "Subscribe",
              checked: false,
              phx_click: "toggle-subscription"
            }
          }
        ]
      },
      %VariationGroup{
        id: :custom_text,
        variations: [
          %Variation{
            id: :on,
            attributes: %{
              label: "Subscribe",
              on_text: "yes",
              checked: true,
              phx_click: "toggle-subscription"
            }
          },
          %Variation{
            id: :off,
            attributes: %{
              label: "Subscribe",
              off_text: "no",
              checked: false,
              phx_click: "toggle-subscription"
            }
          }
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        label: "Subscribe",
        checked: true,
        phx_click: "toggle-subscription"
      }
    }
  end
end
