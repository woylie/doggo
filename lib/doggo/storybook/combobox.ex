defmodule Doggo.Storybook.Combobox do
  @moduledoc false

  import Doggo.Storybook.Shared

  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def dependent_components, do: [:icon]

  def variations(opts) do
    dependent_components = opts[:dependent_components]

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
        id: :with_blank_option,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "golden_retriever",
          options: [
            {"No preference", ""},
            {"Labrador Retriever", "labrador"},
            {"Golden Retriever", "golden_retriever"},
            {"Bulldog", "bulldog"}
          ]
        }
      },
      %Variation{
        id: :clearable,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          clearable: true,
          value: "golden_retriever",
          options: [
            {"Labrador Retriever", "labrador"},
            {"German Shepherd", "german_shepherd"},
            {"Golden Retriever", "golden_retriever"},
            {"Bulldog", "bulldog"}
          ]
        }
      },
      %Variation{
        id: :with_slots,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          clearable: true,
          value: "golden_retriever",
          options: [
            {"Labrador Retriever", "labrador"},
            {"German Shepherd", "german_shepherd"},
            {"Golden Retriever", "golden_retriever"},
            {"Bulldog", "bulldog"}
          ]
        },
        slots: [
          "<:clear>#{icon(:close, dependent_components)}</:clear>",
          "<:toggle>#{icon(:chevron_down, dependent_components)}</:toggle>"
        ]
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
      },
      %Variation{
        id: :with_groups,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "golden_retriever",
          options: [
            {"Retrievers",
             [
               {"Labrador Retriever", "labrador"},
               {"Golden Retriever", "golden_retriever"}
             ]},
            :hr,
            {"Bulldogs",
             [{"French Bulldog", "french_bulldog"}, {"Bulldog", "bulldog"}]},
            {"German Shepherd", "german_shepherd"}
          ]
        }
      },
      %Variation{
        id: :with_groups_and_descriptions,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          value: "golden_retriever",
          options: [
            {"Retrievers",
             [
               [
                 key: "Labrador Retriever",
                 value: "labrador",
                 description: "Friendly and outgoing"
               ],
               [
                 key: "Golden Retriever",
                 value: "golden_retriever",
                 description: "Intelligent and friendly"
               ]
             ]},
            :hr,
            {"Bulldogs",
             [
               [
                 key: "French Bulldog",
                 value: "french_bulldog",
                 description: "Adaptable and playful"
               ],
               [
                 key: "Bulldog",
                 value: "bulldog",
                 description: "Docile and willful",
                 disabled: true
               ]
             ]},
            [
              key: "German Shepherd",
              value: "german_shepherd",
              description: "Confident and smart"
            ]
          ]
        }
      },
      %Variation{
        id: :with_free_text,
        attributes: %{
          id: "dog-breed-selector",
          name: "breed",
          list_label: "Dog breeds",
          free_text: true,
          free_text_label: "Add breed",
          options: [
            {"Labrador Retriever", "labrador"},
            {"Golden Retriever", "golden_retriever"},
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
      %VariationGroup{
        id: :required,
        template: """
        <form class="stack">
          <.psb-variation-group/>
          <button type="submit" class="button">Submit</button>
        </form>
        """,
        variations: [
          %Variation{
            id: :without_free_text,
            attributes: %{
              id: "dog-breed-selector-required",
              name: "breed",
              list_label: "Dog breeds",
              required: true,
              options: [
                {"Labrador Retriever", "labrador"},
                {"Golden Retriever", "golden_retriever"},
                {"Bulldog", "bulldog"}
              ]
            }
          },
          %Variation{
            id: :with_free_text,
            attributes: %{
              id: "dog-breed-selector-required-free-text",
              name: "other_breed",
              list_label: "Dog breeds",
              required: true,
              free_text: true,
              free_text_label: "Add breed",
              options: [
                {"Labrador Retriever", "labrador"},
                {"Golden Retriever", "golden_retriever"},
                {"Bulldog", "bulldog"}
              ]
            }
          }
        ]
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
