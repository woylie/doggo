defmodule Doggo.Storybook.Carousel do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon, :image]

  def layout, do: :one_column

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Our Dogs", pagination: true},
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Our Dogs", pagination: true},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    image_function =
      if fun = dependent_components[:image] do
        ".#{fun}"
      else
        "img"
      end

    [
      """
      <:previous label="Previous Slide">
        #{icon(:chevron_left, dependent_components)}
      </:previous>
      """,
      """
      <:next label="Next Slide">
        #{icon(:chevron_right, dependent_components)}
      </:next>
      """,
      """
      <:item label="1 of 4">
        <#{image_function}
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog wearing a colorful poncho walks down a fashion show runway."
        />
      </:item>
      """,
      """
      <:item label="2 of 4">
        <#{image_function}
          src="https://github.com/woylie/doggo/blob/main/assets/dog_lavish.jpg?raw=true"
          alt="A dog elegantly attired in a lavish baroque costume, adorned with vibrant Pride colors and embellishments, walks down a runway that blends historical opulence with modern LGBTQ+ Pride symbolism, showcasing a unique fusion of luxury and celebratory expression."
        />
      </:item>
      """,
      """
      <:item label="3 of 4">
        <#{image_function}
          src="https://github.com/woylie/doggo/blob/main/assets/dog_baroque.jpg?raw=true"
          alt="A dog dressed in a sumptuous, baroque-style costume, complete with jewels and intricate embroidery, parades on an ornate runway at a luxurious fashion show, embodying opulence and grandeur."
        />
      </:item>
      """,
      """
      <:item label="4 of 4">
        <#{image_function}
          src="https://github.com/woylie/doggo/blob/main/assets/dog_flamboyant.jpg?raw=true"
          alt="A dog adorned in a lavish, flamboyant outfit, including a large feathered hat and elaborate jewelry, struts confidently down a luxurious fashion show runway, surrounded by bright lights and an enthusiastic audience."
        />
      </:item>
      """
    ]
  end
end
