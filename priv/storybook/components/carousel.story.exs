defmodule Storybook.Components.Carousel do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.carousel/1
  def layout, do: :one_column

  defp chevron_left do
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-chevron-left"
    >
      <path d="m15 18-6-6 6-6" />
    </svg>
    """
  end

  defp chevron_right do
    """
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-chevron-right"
    >
      <path d="m9 18 6-6-6-6" />
    </svg>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Our Dogs", pagination: true},
        slots: [
          """
          <:previous label="Previous Slide">
            #{chevron_left()}
          </:previous>
          """,
          """
          <:next label="Next Slide">
            #{chevron_right()}
          </:next>
          """,
          """
          <:item label="1 of 4">
            <Doggo.image
              src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
              alt="A dog wearing a colorful poncho walks down a fashion show runway."
              ratio={{16, 9}}
            />
          </:item>
          """,
          """
          <:item label="2 of 4">
            <Doggo.image
              src="https://github.com/woylie/doggo/blob/main/assets/dog_lavish.jpg?raw=true"
              alt="A dog elegantly attired in a lavish baroque costume, adorned with vibrant Pride colors and embellishments, walks down a runway that blends historical opulence with modern LGBTQ+ Pride symbolism, showcasing a unique fusion of luxury and celebratory expression."
              ratio={{16, 9}}
            />
          </:item>
          """,
          """
          <:item label="3 of 4">
            <Doggo.image
              src="https://github.com/woylie/doggo/blob/main/assets/dog_baroque.jpg?raw=true"
              alt="A dog dressed in a sumptuous, baroque-style costume, complete with jewels and intricate embroidery, parades on an ornate runway at a luxurious fashion show, embodying opulence and grandeur."
              ratio={{16, 9}}
            />
          </:item>
          """,
          """
          <:item label="4 of 4">
            <Doggo.image
              src="https://github.com/woylie/doggo/blob/main/assets/dog_flamboyant.jpg?raw=true"
              alt="A dog adorned in a lavish, flamboyant outfit, including a large feathered hat and elaborate jewelry, struts confidently down a luxurious fashion show runway, surrounded by bright lights and an enthusiastic audience."
              ratio={{16, 9}}
            />
          </:item>
          """
        ]
      }
    ]
  end
end
