defmodule Storybook.Components.Tabs do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.tabs/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "dog-breed-profiles",
          label: "Dog Breed Profiles"
        },
        slots: [
          """
          <:panel label="Golden Retriever">
            <p>
              Friendly, intelligent, great with families. Origin: Scotland. Needs
              regular exercise.
            </p>
          </:panel>
          """,
          """
          <:panel label="Siberian Husky">
            <p>
              Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
              Loves cold climates.
            </p>
          </:panel>
          """,
          """
          <:panel label="Dachshund">
            <p>
              Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
            </p>
          </:panel>
          """
        ]
      }
    ]
  end
end
