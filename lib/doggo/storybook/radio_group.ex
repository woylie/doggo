defmodule Doggo.Storybook.RadioGroup do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: attributes()
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: Map.put(attributes(), name, value)
    }
  end

  defp attributes do
    %{
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
  end
end
