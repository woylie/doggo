defmodule Doggo.Storybook.Avatar do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{src: src(), alt: "Nora Boston"}
      },
      %Variation{
        id: :image_fallback,
        attributes: %{src: nil, placeholder_src: placeholder_src(), alt: ""}
      },
      %Variation{
        id: :text_fallback,
        attributes: %{src: nil, placeholder_content: "NB"}
      }
    ]
  end

  def modifier_variation_group_template(_name, _opts) do
    """
    <div style="display: flex; flex-wrap: wrap; gap: 1rem; align-items: center">
      <.psb-variation-group/>
    </div>
    """
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{src: src(), alt: "Nora Boston"}
    }
  end

  defp src do
    "https://github.com/woylie/doggo/blob/main/assets/images/dog_square_1.webp?raw=true"
  end

  defp placeholder_src do
    "https://github.com/woylie/doggo/blob/main/assets/images/dog_square_2.webp?raw=true"
  end
end
