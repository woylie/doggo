defmodule Storybook.Components.Image do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.image/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          src:
            "https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true",
          alt:
            "A dog wearing a colorful poncho walks down a fashion show runway.",
          ratio: {16, 9}
        }
      },
      %Variation{
        id: :caption,
        attributes: %{
          src:
            "https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true",
          alt:
            "A dog wearing a colorful poncho walks down a fashion show runway.",
          ratio: {16, 9}
        },
        slots: [
          """
          <:caption>Spotlight on canine couture: A dog fashion show where four-legged models dazzle the runway with the latest in pet apparel.</:caption>
          """
        ]
      }
    ]
  end
end
