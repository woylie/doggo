defmodule Doggo.Storybook.Combobox do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
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
        id: :disabled,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "golden_retriever",
          disabled: true,
          options: [
            {"Labrador Retriever", "labrador"},
            {"Golden Retriever", "golden_retriever"},
            {"Bulldog", "bulldog"}
          ]
        }
      },
      %Variation{
        id: :readonly,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "golden_retriever",
          readonly: true,
          options: [
            {"Labrador Retriever", "labrador"},
            {"Golden Retriever", "golden_retriever"},
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
            [
              key: "Labrador Retriever",
              value: "labrador",
              description: "Friendly and outgoing"
            ],
            [
              key: "German Shepherd",
              value: "german_shepherd",
              description: "Confident and smart"
            ],
            [
              key: "French Bulldog",
              value: "french_bulldog",
              description: "Adaptable and playful",
              disabled: true
            ]
          ]
        }
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, _opts) do
    %{
      attributes: %{
        id: id,
        name: "breed",
        list_label: "Dog breeds",
        value: "labrador",
        options: [
          [
            key: "Labrador Retriever",
            value: "labrador",
            description: "Friendly and outgoing"
          ],
          [
            key: "German Shepherd",
            value: "german_shepherd",
            description: "Confident and smart"
          ]
        ]
      }
    }
  end
end
