defmodule Doggo.Storybook.Combobox do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :only_values,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          value: "Golden Retriever",
          list_label: "Dog breeds",
          options: [
            "Labrador Retriever",
            "German Shepherd",
            "Golden Retriever",
            "French Bulldog",
            "Bulldog"
          ]
        }
      },
      %Variation{
        id: :with_labels,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "french_bulldog",
          options: [
            {"Labrador Retriever", "labrador"},
            {"German Shepherd", "german_shepherd"},
            {"Golden Retriever", "golden_retriever"},
            {"French Bulldog", "french_bulldog"},
            {"Bulldog", "bulldog"}
          ]
        }
      },
      %Variation{
        id: :with_labels_and_descriptions,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "labrador",
          options: [
            {"Labrador Retriever", "labrador", "Friendly and outgoing"},
            {"German Shepherd", "german_shepherd", "Confident and smart"},
            {"Golden Retriever", "golden_retriever",
             "Intelligent and friendly"},
            {"French Bulldog", "french_bulldog", "Adaptable and playful"},
            {"Bulldog", "bulldog", "Docile and willful"}
          ]
        }
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{
        name => value,
        id: "dog-modifier-#{name}-#{value}",
        name: "breed",
        list_label: "Dog breeds",
        value: "labrador",
        options: [
          {"Labrador Retriever", "labrador", "Friendly and outgoing"},
          {"German Shepherd", "german_shepherd", "Confident and smart"},
          {"Golden Retriever", "golden_retriever", "Intelligent and friendly"},
          {"French Bulldog", "french_bulldog", "Adaptable and playful"},
          {"Bulldog", "bulldog", "Docile and willful"}
        ]
      }
    }
  end
end
