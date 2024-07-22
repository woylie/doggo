defmodule Doggo.Storybook.Time do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(_opts) do
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
          formatter: &__MODULE__.format/1,
          value: ~T[12:22:06.003Z]
        }
      },
      %Variation{
        id: :title_formatter,
        description: "Hover over the time to see the title.",
        attributes: %{
          title_formatter: &__MODULE__.format/1,
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

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{value: ~T[12:22:06.003Z]}
    }
  end

  def format(time) do
    "#{time.hour}h #{time.minute}m"
  end
end
