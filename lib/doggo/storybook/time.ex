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
        description: "Hover over the time to see the title",
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
      },
      %Variation{
        id: :timezone,
        description: "Shift DateTime to a different time zone",
        attributes: %{
          value: ~U[2023-02-05 23:22:05Z],
          timezone:
            if time_zone_db_configured?() do
              "Asia/Tokyo"
            end
        },
        template:
          if !time_zone_db_configured?() do
            """
            <p>
              This example requires a <a href="https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database">time zone database to be configured</a>.
            </p>
            """
          end
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

  defp time_zone_db_configured? do
    Application.get_env(:elixir, :time_zone_database) !=
      Calendar.UTCOnlyTimeZoneDatabase
  end
end
