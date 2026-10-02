if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.Datetime do
    @moduledoc false
    alias PhoenixStorybook.Stories.Variation
    alias PhoenixStorybook.Stories.VariationGroup

    @value ~U[2023-02-05 12:22:06.003Z]
    def variations(_opts) do
      [
        %VariationGroup{
          id: :values,
          description: "Values",
          variations: [
            %Variation{id: :datetime, attributes: %{value: @value}},
            %Variation{
              id: :naive_datetime,
              attributes: %{value: ~N[2023-02-05 12:22:06.003]}
            }
          ]
        },
        %VariationGroup{
          id: :formatters,
          description: "Formatters",
          note: "Hover over the second value to see the title.",
          variations: [
            %Variation{
              id: :formatter,
              attributes: %{formatter: &DateTime.to_unix/1, value: @value}
            },
            %Variation{
              id: :title_formatter,
              attributes: %{title_formatter: &DateTime.to_unix/1, value: @value}
            }
          ]
        },
        %VariationGroup{
          id: :precision,
          description: "Precision",
          note: """
          `precision` truncates the value for both the display text and the
          `datetime` attribute.
          """,
          variations:
            for precision <- [:minute, :second, :millisecond, :microsecond] do
              %Variation{
                id: precision,
                attributes: %{
                  value: ~U[2023-02-05 12:22:06.003412Z],
                  precision: precision
                }
              }
            end
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
        },
        %VariationGroup{
          id: :localize_styles,
          description: "Localized styles",
          variations:
            for style <- [true, :short, :medium, :long, :full] do
              %Variation{
                id: if(style == true, do: :default_style, else: style),
                attributes: %{value: @value, localize: style}
              }
            end
        },
        %VariationGroup{
          id: :localize_options,
          description: "Localized options and patterns",
          note: """
          Pass options to choose the parts, pass a pattern to enforce a fixed
          format.
          """,
          variations: [
            %Variation{
              id: :options,
              attributes: %{
                value: @value,
                localize: [weekday: :short, hour: :numeric, minute: :"2-digit"]
              }
            },
            %Variation{
              id: :pattern,
              attributes: %{value: @value, localize: "%Y-%m-%d %H:%M"}
            },
            %Variation{
              id: :hour_cycle,
              attributes: %{
                value: @value,
                localize: [style: :short, hour_cycle: :h23]
              }
            },
            %Variation{
              id: :title,
              attributes: %{
                value: @value,
                localize: [style: :short, title: :full]
              }
            },
            %Variation{
              id: :title_pattern,
              attributes: %{
                value: @value,
                localize: [style: :short, title: "%Y-%m-%d %H:%M %z"]
              }
            }
          ]
        },
        %VariationGroup{
          id: :localize_zones,
          description: "Localized time zones",
          note: """
          The first value is in your time zone, the second in the zone the server
          rendered in, and the third in New York.
          """,
          variations: [
            %Variation{
              id: :viewer,
              attributes: %{value: @value, localize: :long}
            },
            %Variation{
              id: :server,
              attributes: %{
                value: @value,
                timezone:
                  if time_zone_db_configured?() do
                    "Asia/Tokyo"
                  end,
                localize: [style: :long, zone: :server]
              }
            },
            %Variation{
              id: :named,
              attributes: %{
                value: @value,
                localize: [style: :long, zone: "America/New_York"]
              }
            }
          ]
        }
      ]
    end

    def modifier_variation_base(_id, _name, _value, _opts) do
      %{
        attributes: %{value: @value}
      }
    end

    defp time_zone_db_configured? do
      Application.get_env(:elixir, :time_zone_database) !=
        Calendar.UTCOnlyTimeZoneDatabase
    end
  end
end
