defmodule Storybook.Components.Switch do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.switch/1

  def variations do
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
end
