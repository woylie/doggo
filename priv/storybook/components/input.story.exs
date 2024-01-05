defmodule Storybook.Components.Input do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.input/1
  # def imports, do: [{Phoenix.Component, [simple_form: 1]}]

  def template do
    """
    <Phoenix.Component.form for={%{}} as={:story} :let={f}>
      <.psb-variation-group field={f[:field]} />
    </Phoenix.Component.form>
    """
  end

  def variations do
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
            id: :select,
            attributes: %{
              label: "Select",
              type: "select",
              options: ["Option 1", "Option 2", "Option 3"]
            }
          },
          %Variation{
            id: :multiple_select,
            attributes: %{
              label: "Multiple select",
              type: "select",
              multiple: true,
              options: ["Option 1", "Option 2", "Option 3"]
            }
          },
          %Variation{
            id: :radio_group,
            attributes: %{
              label: "Radio group",
              type: "radio-group",
              options: ["Option 1", "Option 2", "Option 3"]
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
            id: :checkbox_group,
            attributes: %{
              label: "Checkbox group",
              type: "checkbox-group",
              options: ["Option 1", "Option 2", "Option 3"]
            }
          }
        ]
      },
      %VariationGroup{
        id: :description_and_errors,
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
              <:addon_left>Tell us about yourself.</:addon_left>
              """
            ]
          }
        ]
      },
      %VariationGroup{
        id: :addons,
        variations: [
          %Variation{
            id: :addon_left,
            attributes: %{
              type: "text",
              label: "Left",
              placeholder: "Some text"
            },
            slots: [
              """
              <:addon_left>
                <Doggo.icon>
                  #{mail_icon()}
                </Doggo.icon>
              </:addon_left>
              """
            ]
          },
          %Variation{
            id: :addon_right,
            attributes: %{
              type: "text",
              label: "Right",
              placeholder: "Some text"
            },
            slots: [
              """
              <:addon_right>
                <Doggo.icon>
                  #{mail_icon()}
                </Doggo.icon>
              </:addon_right>
              """
            ]
          },
          %Variation{
            id: :addon_left_and_right,
            attributes: %{
              type: "text",
              label: "Left and right",
              placeholder: "Some text"
            },
            slots: [
              """
              <:addon_left>
                <Doggo.icon>
                  #{mail_icon()}
                </Doggo.icon>
              </:addon_left>
              <:addon_right>
                <Doggo.icon>
                  #{check_icon()}
                </Doggo.icon>
              </:addon_right>
              """
            ]
          }
        ]
      }
    ]
  end

  defp mail_icon do
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
      class="lucide lucide-mail"
    >
      <rect width="20" height="16" x="2" y="4" rx="2" /><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" />
    </svg>
    """
  end

  defp check_icon do
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
      class="lucide lucide-check"
    >
      <path d="M20 6 9 17l-5-5" />
    </svg>
    """
  end
end
