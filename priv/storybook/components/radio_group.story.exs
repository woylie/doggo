defmodule Storybook.Components.RadioGroup do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.radio_group/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "favorite_dog_rg",
          name: "favorite_dog",
          label: "Favorite Dog",
          value: "golden_retriever",
          options: [
            {"Labrador Retriever", "labrador"},
            {"German Shepherd", "german_shepherd"},
            {"Golden Retriever", "golden_retriever"},
            {"French Bulldog", "french_bulldog"},
            {"Beagle", "beagle"}
          ]
        }
      }
    ]
  end
end
