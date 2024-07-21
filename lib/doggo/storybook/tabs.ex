defmodule Doggo.Storybook.Tabs do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "dog-breed-profiles",
          label: "Dog Breed Profiles"
        },
        slots: slots()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value},
      slots: slots()
    }
  end

  defp slots do
    [
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
  end
end
