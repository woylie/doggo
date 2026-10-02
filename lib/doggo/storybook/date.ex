if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.Date do
    @moduledoc false
    alias PhoenixStorybook.Stories.Variation
    alias PhoenixStorybook.Stories.VariationGroup

    def variations(_opts) do
      [
        %VariationGroup{
          id: :values,
          description: "Values",
          note: """
          For `DateTime` and `NaiveDateTime` values, only the date is rendered,
          but the `datetime` attribute contains the full value.
          """,
          variations: [
            %Variation{id: :date, attributes: %{value: ~D[2023-02-05]}},
            %Variation{
              id: :datetime,
              attributes: %{value: ~U[2023-02-05 12:08:30Z]}
            },
            %Variation{
              id: :naive_datetime,
              attributes: %{value: ~N[2023-02-05 12:08:30]}
            }
          ]
        },
        %VariationGroup{
          id: :formatters,
          description: "Formatters",
          note: """
          The formatters receive the full date. Hover over the second date to see
          the title.
          """,
          variations: [
            %Variation{
              id: :formatter,
              attributes: %{
                formatter: &Date.to_gregorian_days/1,
                value: ~D[2023-02-05]
              }
            },
            %Variation{
              id: :title_formatter,
              attributes: %{
                title_formatter: &Date.to_gregorian_days/1,
                value: ~D[2023-02-05]
              }
            }
          ]
        },
        %VariationGroup{
          id: :precision,
          description: "Precision",
          note: """
          `precision` limits both the default display text and the `datetime`
          attribute.
          """,
          variations:
            for precision <- [:year, :month, :month_day, :day] do
              %Variation{
                id: precision,
                attributes: %{value: ~D[1980-05-17], precision: precision}
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
                attributes: %{value: ~D[2023-02-05], localize: style}
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
                value: ~D[2023-02-05],
                localize: [weekday: :long, day: :numeric, month: :long]
              }
            },
            %Variation{
              id: :pattern,
              attributes: %{value: ~D[2023-02-05], localize: "%Y-%m-%d"}
            },
            %Variation{
              id: :title,
              attributes: %{
                value: ~D[2023-02-05],
                localize: [style: :short, title: :full]
              }
            },
            %Variation{
              id: :title_pattern,
              attributes: %{
                value: ~D[2023-02-05],
                localize: [style: :short, title: "%Y-%m-%d"]
              }
            }
          ]
        }
      ]
    end

    def modifier_variation_base(_id, _name, _value, _opts) do
      %{
        attributes: %{value: ~D[2023-02-05]}
      }
    end

    defp time_zone_db_configured? do
      Application.get_env(:elixir, :time_zone_database) !=
        Calendar.UTCOnlyTimeZoneDatabase
    end
  end
end
