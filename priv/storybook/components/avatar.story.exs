defmodule Storybook.Components.Avatar do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.avatar/1

  @src "https://github.com/woylie/doggo/blob/main/assets/dog_avatar.jpg?raw=true"
  @placeholder_src "https://github.com/woylie/doggo/blob/main/assets/dog_avatar_placeholder.jpg?raw=true"

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{src: @src}
      },
      %Variation{
        id: :image_fallback,
        attributes: %{src: nil, placeholder: {:src, @placeholder_src}}
      },
      %Variation{
        id: :text_fallback,
        attributes: %{src: nil, placeholder: "A"}
      },
      %Variation{
        id: :circle,
        attributes: %{src: @src, circle: true}
      },
      %VariationGroup{
        id: :sizes,
        variations:
          for size <- Doggo.sizes() do
            %Variation{
              id: size,
              attributes: %{src: @src, size: size}
            }
          end
      }
    ]
  end
end
