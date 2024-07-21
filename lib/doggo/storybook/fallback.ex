defmodule Doggo.Storybook.Fallback do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation
  alias PhoenixStorybook.Stories.VariationGroup

  def variations do
    [
      %VariationGroup{
        id: :default,
        variations: [
          %Variation{
            id: :with_value,
            attributes: %{value: "George"}
          },
          %Variation{
            id: :with_nil,
            attributes: %{value: nil}
          }
        ]
      },
      %VariationGroup{
        id: :with_formatter,
        variations: [
          %Variation{
            id: :with_value,
            attributes: %{
              value: ~U[2032-06-02 08:20:04Z],
              formatter: &DateTime.to_unix/1
            }
          },
          %Variation{
            id: :with_nil,
            attributes: %{
              value: nil,
              formatter: &DateTime.to_unix/1
            }
          }
        ]
      },
      %VariationGroup{
        id: :with_custom_texts,
        variations: [
          %Variation{
            id: :with_value,
            attributes: %{
              value: "Mary",
              placeholder: "n/a",
              accessibility_text: "not available"
            }
          },
          %Variation{
            id: :with_nil,
            attributes: %{
              value: "",
              placeholder: "n/a",
              accessibility_text: "not available"
            }
          }
        ]
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, value: nil}
    }
  end
end
