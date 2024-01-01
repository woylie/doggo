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
        variations:
          for level <- Doggo.variants() do
            %Variation{
              id: level,
              attributes: %{level: level},
              slots: ["This is an alert with level '#{level}'."]
            }
          end
      }
    ]
  end
end
