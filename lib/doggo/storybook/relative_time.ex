if Code.ensure_loaded?(PhoenixStorybook.Story) do
  defmodule Doggo.Storybook.RelativeTime do
    @moduledoc false
    alias PhoenixStorybook.Stories.Variation
    alias PhoenixStorybook.Stories.VariationGroup

    def variations(_opts) do
      now = DateTime.utc_now()

      [
        %VariationGroup{
          id: :values,
          description: "Past and future",
          note: """
          Hover over a value to see the absolute value in the title.
          """,
          variations: [
            %Variation{
              id: :seconds_ago,
              attributes: %{value: DateTime.add(now, -20, :second)}
            },
            %Variation{
              id: :minutes_ago,
              attributes: %{value: DateTime.add(now, -5, :minute)}
            },
            %Variation{
              id: :hours_ago,
              attributes: %{value: DateTime.add(now, -3, :hour)}
            },
            %Variation{
              id: :days_ago,
              attributes: %{value: DateTime.add(now, -3, :day)}
            },
            %Variation{
              id: :in_minutes,
              attributes: %{value: DateTime.add(now, 10, :minute)}
            }
          ]
        },
        %VariationGroup{
          id: :dates,
          description: "Dates",
          note: """
          A `Date` is compared by calendar day.
          """,
          variations: [
            %Variation{
              id: :yesterday,
              attributes: %{value: Date.add(Date.utc_today(), -1)}
            },
            %Variation{
              id: :in_two_days,
              attributes: %{value: Date.add(Date.utc_today(), 2)}
            }
          ]
        },
        %VariationGroup{
          id: :formats,
          description: "Formats",
          variations:
            for format <- [:long, :short, :narrow] do
              %Variation{
                id: format,
                attributes: %{
                  value: DateTime.add(now, -3, :hour),
                  format: format
                }
              }
            end
        },
        %VariationGroup{
          id: :numeric,
          description: "Numeric",
          note: """
          `:always` never writes words such as "yesterday".
          """,
          variations:
            for numeric <- [:auto, :always] do
              %Variation{
                id: numeric,
                attributes: %{
                  value: DateTime.add(now, -1, :day),
                  numeric: numeric
                }
              }
            end
        },
        %VariationGroup{
          id: :updates,
          description: "Updates",
          note: """
          The first value is converted once, the second keeps counting while the
          page is open.
          """,
          variations: [
            %Variation{
              id: :once,
              attributes: %{value: DateTime.add(now, -50, :second)}
            },
            %Variation{
              id: :sync,
              attributes: %{value: DateTime.add(now, -50, :second), sync: true}
            }
          ]
        },
        %VariationGroup{
          id: :threshold,
          description: "Threshold",
          note: """
          Past a threshold of one day, the second value shows the absolute value
          in the user's format.
          """,
          variations: [
            %Variation{
              id: :within,
              attributes: %{
                value: DateTime.add(now, -3, :hour),
                threshold: Duration.new!(day: 1),
                localize: :medium
              }
            },
            %Variation{
              id: :past,
              attributes: %{
                value: DateTime.add(now, -3, :day),
                threshold: Duration.new!(day: 1),
                localize: :medium
              }
            }
          ]
        },
        %VariationGroup{
          id: :title,
          description: "Title",
          note: """
          Hover to see the title. The first value has the server's text, the
          second the `title:` style, and the third the `title:` pattern.
          """,
          variations: [
            %Variation{
              id: :server_text,
              attributes: %{value: DateTime.add(now, -3, :hour)}
            },
            %Variation{
              id: :style,
              attributes: %{
                value: DateTime.add(now, -3, :hour),
                localize: [title: :full]
              }
            },
            %Variation{
              id: :pattern,
              attributes: %{
                value: DateTime.add(now, -3, :hour),
                localize: [title: "%Y-%m-%d %H:%M"]
              }
            }
          ]
        }
      ]
    end

    def modifier_variation_base(_id, _name, _value, _opts) do
      %{
        attributes: %{value: DateTime.add(DateTime.utc_now(), -5, :minute)}
      }
    end
  end
end
