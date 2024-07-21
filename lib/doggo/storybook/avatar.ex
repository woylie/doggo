defmodule Doggo.Storybook.Avatar do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{src: src()}
      },
      %Variation{
        id: :image_fallback,
        attributes: %{src: nil, placeholder: {:src, placeholder_src()}}
      },
      %Variation{
        id: :text_fallback,
        attributes: %{src: nil, placeholder: "A"}
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, :src => src()}
    }
  end

  defp src do
    "https://github.com/woylie/doggo/blob/main/assets/dog_avatar.jpg?raw=true"
  end

  defp placeholder_src do
    "https://github.com/woylie/doggo/blob/main/assets/dog_avatar_placeholder.jpg?raw=true"
  end
end
