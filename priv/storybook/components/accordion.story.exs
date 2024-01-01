defmodule Storybook.Components.Accordion do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.accordion/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "dog-breeds"
        },
        slots: [
          """
          <:section title="Golden Retriever">
            <p>
              Friendly, intelligent, great with families. Origin: Scotland. Needs
              regular exercise.
            </p>
          </:section>
          """,
          """
          <:section title="Siberian Husky">
            <p>
              Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
              Loves cold climates.
            </p>
          </:section>
          """,
          """
          <:section title="Dachshund">
            <p>
              Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
            </p>
          </:section>
          """
        ]
      }
    ]
  end
end
