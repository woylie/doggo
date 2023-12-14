defmodule Storybook.Components.Alert do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.alert/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: ["This is an alert."]
      },
      %Variation{
        id: :title,
        attributes: %{title: "This is the title."},
        slots: ["This is the body."]
      },
      %Variation{
        id: :close_button,
        attributes: %{on_close: JS.push("close-alert")},
        slots: ["This is the body."]
      },
      %VariationGroup{
        id: :levels,
        variations: [
          %Variation{
            id: :info,
            attributes: %{level: :info},
            slots: ["This is an alert with level 'info'."]
          },
          %Variation{
            id: :success,
            attributes: %{level: :success},
            slots: ["This is an alert with level 'success'."]
          },
          %Variation{
            id: :warning,
            attributes: %{level: :warning},
            slots: ["This is an alert with level 'warning'."]
          },
          %Variation{
            id: :error,
            attributes: %{level: :error},
            slots: ["This is an alert with level 'error'."]
          }
        ]
      }
    ]
  end
end
