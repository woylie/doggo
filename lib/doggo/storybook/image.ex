defmodule Doggo.Storybook.Image do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: attributes()
      },
      %Variation{
        id: :caption,
        attributes: attributes(),
        slots: [
          """
          <:caption>Spotlight on canine couture: A dog fashion show where four-legged models dazzle the runway with the latest in pet apparel.</:caption>
          """
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value) do
    %{
      attributes: attributes()
    }
  end

  defp attributes do
    %{
      src:
        "https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true",
      alt: "A dog wearing a colorful poncho walks down a fashion show runway.",
      ratio: {16, 9}
    }
  end
end
