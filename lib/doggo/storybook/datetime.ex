defmodule Doggo.Storybook.Datetime do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{value: ~U[2023-02-05 12:22:06.003Z]}
      },
      %Variation{
        id: :formatter,
        attributes: %{
          formatter: &DateTime.to_unix/1,
          value: ~U[2023-02-05 12:22:06.003Z]
        }
      },
      %Variation{
        id: :title_formatter,
        description: "Hover over the datetime to see the title.",
        attributes: %{
          title_formatter: &DateTime.to_unix/1,
          value: ~U[2023-02-05 12:22:06.003Z]
        }
      },
      %Variation{
        id: :precision,
        attributes: %{
          value: ~U[2023-02-05 12:22:06.003Z],
          precision: :minute
        }
      }
    ]
  end

  def modifier_variation(name, value) do
    %{
      attributes: %{name => value, value: ~U[2023-02-05 12:22:06.003Z]}
    }
  end
end
