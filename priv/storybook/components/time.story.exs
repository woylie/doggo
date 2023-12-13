defmodule Storybook.Components.Time do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.time/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{value: ~T[12:22:06.003Z]}
      },
      %Variation{
        id: :datetime,
        attributes: %{value: ~U[2023-02-05 12:22:06.003Z]}
      },
      %Variation{
        id: :formatter,
        attributes: %{
          formatter: &Storybook.Components.Time.format/1,
          value: ~T[12:22:06.003Z]
        }
      },
      %Variation{
        id: :title_formatter,
        description: "Hover over the time to see the title.",
        attributes: %{
          title_formatter: &Storybook.Components.Time.format/1,
          value: ~T[12:22:06.003Z]
        }
      },
      %Variation{
        id: :precision,
        attributes: %{
          value: ~T[12:22:06.003Z],
          precision: :minute
        }
      }
    ]
  end

  def format(time) do
    "#{time.hour}h #{time.minute}m"
  end
end
