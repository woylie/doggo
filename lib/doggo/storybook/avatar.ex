defmodule Doggo.Storybook.Avatar do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{src: src()}
      },
      %Variation{
        id: :image_fallback,
        attributes: %{src: nil, placeholder_src: placeholder_src()}
      },
      %Variation{
        id: :text_fallback,
        attributes: %{src: nil, placeholder_content: "A"}
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{:src => src()}
    }
  end

  defp src do
    "https://github.com/woylie/doggo/blob/main/assets/dog_avatar.jpg?raw=true"
  end

  defp placeholder_src do
    "https://github.com/woylie/doggo/blob/main/assets/dog_avatar_placeholder.jpg?raw=true"
  end
end
