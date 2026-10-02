if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.Field do
    @moduledoc false

    import Doggo.Storybook.Shared

    alias PhoenixStorybook.Stories.Variation
    alias PhoenixStorybook.Stories.VariationGroup

    def dependent_components, do: [:icon]

    def template do
      """
      <Phoenix.Component.form
        for={%{}}
        as={:story}
        :let={f}
        style="display: grid; gap: 1rem; inline-size: 100%"
      >
        <.psb-variation-group field={f[:field]} />
      </Phoenix.Component.form>
      """
    end

    def variations(opts) do
      removed = for {type, nil} <- opts[:extra][:types] || %{}, do: type

      opts
      |> all_variations()
      |> Enum.map(&without_types(&1, removed))
      |> Enum.reject(&match?(%VariationGroup{variations: []}, &1))
    end

    defp without_types(%VariationGroup{} = group, removed) do
      %{
        group
        | variations:
            Enum.reject(group.variations, &(&1.attributes[:type] in removed))
      }
    end

    defp without_types(variation, _removed), do: variation

    defp all_variations(opts) do
      dependent_components = opts[:dependent_components]

      [
        %VariationGroup{
          id: :basic_inputs,
          variations: [
            %Variation{
              id: :text,
              attributes: %{
                type: "text",
                label: "Text",
                placeholder: "Some text"
              }
            },
            %Variation{
              id: :email,
              attributes: %{
                type: "email",
                label: "E-mail",
                placeholder: "email@example.com"
              }
            },
            %Variation{
              id: :password,
              attributes: %{
                type: "password",
                label: "Password",
                placeholder: "12345678"
              }
            },
            %Variation{
              id: :number,
              attributes: %{
                type: "number",
                label: "Number",
                placeholder: "250"
              }
            },
            %Variation{
              id: :search,
              attributes: %{
                type: "search",
                label: "Search",
                placeholder: "Search term"
              }
            },
            %Variation{
              id: :tel,
              attributes: %{
                type: "tel",
                label: "Phone number",
                placeholder: "+818012345678"
              }
            },
            %Variation{
              id: :url,
              attributes: %{
                type: "url",
                label: "URL",
                placeholder: "https://www.msf.org"
              }
            },
            %Variation{
              id: :textarea,
              attributes: %{
                type: "textarea",
                label: "Textarea",
                placeholder: "Some text",
                rows: "5"
              }
            },
            %Variation{
              id: :range,
              attributes: %{
                type: "range",
                label: "Range",
                min: "0",
                max: "100",
                step: "10"
              }
            },
            %Variation{
              id: :color,
              attributes: %{
                type: "color",
                label: "Color"
              }
            },
            %Variation{
              id: :date,
              attributes: %{
                type: "date",
                label: "Date"
              }
            },
            %Variation{
              id: :time,
              attributes: %{
                type: "time",
                label: "Time"
              }
            },
            %Variation{
              id: :datetime_local,
              attributes: %{
                type: "datetime-local",
                label: "Datetime local"
              }
            },
            %Variation{
              id: :week,
              attributes: %{
                type: "week",
                label: "Week"
              }
            },
            %Variation{
              id: :file,
              attributes: %{
                type: "file",
                label: "File"
              }
            },
            %Variation{
              id: :file_multiple,
              attributes: %{
                type: "file",
                label: "Files",
                multiple: true
              }
            },
            %Variation{
              id: :select,
              attributes: %{
                label: "Select",
                type: "select",
                options: ["Small", "Medium", "Large"]
              }
            },
            %Variation{
              id: :select_with_prompt,
              attributes: %{
                label: "Select with prompt",
                type: "select",
                prompt: "Choose a size",
                options: ["Small", "Medium", "Large"]
              }
            },
            %Variation{
              id: :multiple_select,
              attributes: %{
                label: "Multiple select",
                type: "select",
                multiple: true,
                options: ["Playful", "Loyal", "Energetic"]
              }
            },
            %Variation{
              id: :radio_group,
              attributes: %{
                label: "Radio group",
                type: "radio-group",
                options: ["Puppy", "Adult", "Senior"]
              }
            },
            %Variation{
              id: :checkbox,
              attributes: %{
                label: "Checkbox",
                type: "checkbox"
              }
            },
            %Variation{
              id: :switch,
              attributes: %{
                label: "Switch",
                type: "switch"
              }
            },
            %Variation{
              id: :switch_with_state_text,
              attributes: %{
                label: "Switch with state text",
                type: "switch",
                on_text: "Enabled",
                off_text: "Disabled"
              }
            },
            %Variation{
              id: :hidden_label,
              attributes: %{
                label: "Search",
                hide_label: true,
                type: "search",
                placeholder: "Search breeds"
              }
            },
            %Variation{
              id: :checkbox_group,
              attributes: %{
                label: "Checkbox group",
                type: "checkbox-group",
                options: [
                  "Garden required",
                  "Good with cats",
                  "Good with children"
                ]
              }
            }
          ]
        },
        %VariationGroup{
          id: :required_inputs,
          variations: [
            %Variation{
              id: :text,
              attributes: %{
                type: "text",
                label: "Text",
                placeholder: "Some text",
                validations: [required: true]
              }
            },
            %Variation{
              id: :select,
              attributes: %{
                label: "Select",
                type: "select",
                options: ["Small", "Medium", "Large"],
                validations: [required: true]
              }
            },
            %Variation{
              id: :radio_group,
              attributes: %{
                label: "Radio group",
                type: "radio-group",
                options: ["Puppy", "Adult", "Senior"],
                validations: [required: true]
              }
            },
            %Variation{
              id: :checkbox,
              attributes: %{
                label: "Checkbox",
                type: "checkbox",
                validations: [required: true]
              }
            },
            %Variation{
              id: :switch,
              attributes: %{
                label: "Switch",
                type: "switch",
                validations: [required: true]
              }
            },
            %Variation{
              id: :checkbox_group,
              attributes: %{
                label: "Checkbox group",
                type: "checkbox-group",
                options: [
                  "Garden required",
                  "Good with cats",
                  "Good with children"
                ],
                validations: [required: true]
              }
            }
          ]
        },
        %VariationGroup{
          id: :autocomplete,
          description: "Autocomplete with datalist",
          variations: [
            %Variation{
              id: :only_values,
              attributes: %{
                type: "text",
                label: "Dog breed",
                placeholder: "Beagle",
                options: [
                  "Labrador Retriever",
                  "German Shepherd",
                  "Golden Retriever",
                  "Bulldog",
                  "Beagle",
                  "Poodle",
                  "Rottweiler",
                  "Yorkshire Terrier",
                  "Boxer",
                  "Dachshund"
                ]
              }
            },
            %Variation{
              id: :labels_and_values,
              attributes: %{
                type: "text",
                label: "Dog breed",
                placeholder: "Poodle",
                options: [
                  {"Labrador Retriever", "labrador_retriever"},
                  {"German Shepherd", "german_shepherd"},
                  {"Golden Retriever", "golden_retriever"},
                  {"Bulldog", "bulldog"},
                  {"Beagle", "beagle"},
                  {"Poodle", "poodle"},
                  {"Rottweiler", "rottweiler"},
                  {"Yorkshire Terrier", "yorkshire_terrier"},
                  {"Boxer", "boxer"},
                  {"Dachshund", "dachshund"}
                ]
              }
            }
          ]
        },
        %VariationGroup{
          id: :description_and_errors,
          variations: [
            %Variation{
              id: :description,
              attributes: %{
                type: "text",
                label: "With description",
                placeholder: "Some text"
              },
              slots: [
                """
                <:description>Tell us about yourself.</:description>
                """
              ]
            },
            %Variation{
              id: :errors,
              attributes: %{
                type: "text",
                label: "Text",
                placeholder: "With errors",
                errors: ["too many characters", "too boring"]
              }
            },
            %Variation{
              id: :description_and_errors,
              attributes: %{
                type: "text",
                label: "With description and errors",
                placeholder: "Some text",
                errors: ["too many characters"]
              },
              slots: [
                """
                <:description>Tell us about yourself.</:description>
                """
              ]
            },
            %Variation{
              id: :radio_group_with_option_descriptions,
              attributes: %{
                label: "Radio group with option descriptions",
                type: "radio-group",
                options: [
                  [
                    key: "Daily",
                    value: "daily",
                    description: "One digest each morning."
                  ],
                  [
                    key: "Weekly",
                    value: "weekly",
                    description: "Every Monday."
                  ],
                  [
                    key: "Never",
                    value: "never",
                    description: "No email at all."
                  ]
                ]
              }
            },
            %Variation{
              id: :checkbox_group_with_option_descriptions,
              attributes: %{
                label: "Checkbox group with option descriptions",
                type: "checkbox-group",
                options: [
                  [
                    key: "Email",
                    value: "email",
                    description: "Sent to your primary address."
                  ],
                  [
                    key: "SMS",
                    value: "sms",
                    description: "Standard rates apply."
                  ],
                  [
                    key: "Push",
                    value: "push",
                    description: "Requires the mobile app."
                  ]
                ]
              }
            },
            %Variation{
              id: :radio_group_with_descriptions_and_errors,
              attributes: %{
                label: "Radio group",
                type: "radio-group",
                errors: ["select how often you want to hear from us"],
                options: [
                  [
                    key: "Daily",
                    value: "daily",
                    description: "One digest each morning."
                  ],
                  [
                    key: "Weekly",
                    value: "weekly",
                    description: "Every Monday."
                  ],
                  [
                    key: "Never",
                    value: "never",
                    description: "No email at all."
                  ]
                ]
              }
            },
            %Variation{
              id: :radio_group_with_field_description,
              attributes: %{
                label: "Radio group",
                type: "radio-group",
                options: ["Puppy", "Adult", "Senior"]
              },
              slots: [
                """
                <:description>Applies to the whole group.</:description>
                """
              ]
            },
            %Variation{
              id: :checkbox_group_with_errors,
              attributes: %{
                label: "Checkbox group",
                type: "checkbox-group",
                options: [
                  "Garden required",
                  "Good with cats",
                  "Good with children"
                ],
                errors: ["select at least one option"]
              }
            }
          ]
        },
        %VariationGroup{
          id: :addons,
          variations: [
            %Variation{
              id: :addon_start,
              attributes: %{
                type: "text",
                label: "Start",
                placeholder: "Some text"
              },
              slots: [
                """
                <:addon_start>
                  #{icon(:mail, dependent_components)}
                </:addon_start>
                """
              ]
            },
            %Variation{
              id: :addon_end,
              attributes: %{
                type: "text",
                label: "End",
                placeholder: "Some text"
              },
              slots: [
                """
                <:addon_end>
                  #{icon(:mail, dependent_components)}
                </:addon_end>
                """
              ]
            },
            %Variation{
              id: :addon_start_and_end,
              attributes: %{
                type: "text",
                label: "Start and end",
                placeholder: "Some text"
              },
              slots: [
                """
                <:addon_start>
                  #{icon(:mail, dependent_components)}
                </:addon_start>
                <:addon_end>
                  #{icon(:check, dependent_components)}
                </:addon_end>
                """
              ]
            }
          ]
        }
      ]
    end

    def modifier_variation_base(_id, _name, value, _opts) do
      %{
        attributes: %{
          type: "text",
          label: "Text",
          placeholder: to_string(value || "nil")
        }
      }
    end
  end
end
