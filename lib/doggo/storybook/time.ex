if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.Time do
    @moduledoc false
    alias PhoenixStorybook.Stories.Variation
    alias PhoenixStorybook.Stories.VariationGroup

    @value ~T[18:05:09.003]
    @datetime ~U[2023-02-05 18:05:09.003Z]

    def variations(_opts) do
      [
        %VariationGroup{
          id: :values,
          description: "Values",
          note: """
          For `DateTime` and `NaiveDateTime` values, only the time is rendered,
          but the `datetime` attribute contains the full value.
          """,
          variations: [
            %Variation{id: :time, attributes: %{value: @value}},
            %Variation{
              id: :datetime,
              attributes: %{value: ~U[2023-02-05 12:22:06.003Z]}
            }
          ]
        },
        %VariationGroup{
          id: :formatters,
          description: "Formatters",
          note: "Hover over the second time to see the title.",
          variations: [
            %Variation{
              id: :formatter,
              attributes: %{formatter: &__MODULE__.format/1, value: @value}
            },
            %Variation{
              id: :title_formatter,
              attributes: %{
                title_formatter: &__MODULE__.format/1,
                value: @value
              }
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
            for precision <- [:minute, :second, :millisecond] do
              %Variation{
                id: precision,
                attributes: %{value: @value, precision: precision}
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
          note: """
          A `Time` has no time zone, so the styles that use one fall back to
          `:medium`.
          """,
          variations:
            for style <- [true, :short, :medium, :long, :full] do
              %Variation{
                id: if(style == true, do: :default_style, else: style),
                attributes: %{value: @value, localize: style}
              }
            end
        },
        %VariationGroup{
          id: :localize_styles_datetime,
          description: "Localized styles of a DateTime",
          note: """
          The value is 18:05:09 UTC, shown in your time zone. `:long` and `:full`
          include the zone.
          """,
          variations:
            for style <- [true, :short, :medium, :long, :full] do
              %Variation{
                id:
                  if(style == true,
                    do: :datetime_default_style,
                    else: :"datetime_#{style}"
                  ),
                attributes: %{value: @datetime, localize: style}
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
                localize: [hour: :"2-digit"]
              }
            },
            %Variation{
              id: :pattern,
              attributes: %{value: @value, localize: "%I:%M %p"}
            },
            %Variation{
              id: :hour_cycle_h23,
              attributes: %{
                value: @value,
                localize: [style: :short, hour_cycle: :h23]
              }
            },
            %Variation{
              id: :hour_cycle_h12,
              attributes: %{
                value: @value,
                localize: [style: :short, hour_cycle: :h12]
              }
            },
            %Variation{
              id: :server_zone,
              attributes: %{
                value: @datetime,
                timezone:
                  if time_zone_db_configured?() do
                    "Asia/Tokyo"
                  end,
                localize: [style: :short, zone: :server]
              }
            },
            %Variation{
              id: :title,
              attributes: %{
                value: @datetime,
                localize: [style: :short, title: :full]
              }
            },
            %Variation{
              id: :title_pattern,
              attributes: %{
                value: @value,
                localize: [style: :short, title: "%H:%M:%S"]
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

    def format(time) do
      "#{time.hour}h #{time.minute}m"
    end

    defp time_zone_db_configured? do
      Application.get_env(:elixir, :time_zone_database) !=
        Calendar.UTCOnlyTimeZoneDatabase
    end
  end
end
