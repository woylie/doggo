defmodule Storybook.Components.Date do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.date/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{value: ~D[2023-02-05]}
      },
      %Variation{
        id: :datetime,
        attributes: %{value: ~U[2023-02-05 12:08:30Z]}
      },
      %Variation{
        id: :formatter,
        attributes: %{
          formatter: &Date.to_gregorian_days/1,
          value: ~D[2023-02-05]
        }
      },
      %Variation{
        id: :title_formatter,
        description: "Hover over the date to see the title.",
        attributes: %{
          title_formatter: &Date.to_gregorian_days/1,
          value: ~D[2023-02-05]
        }
      }
    ]
  end
end
