defmodule Storybook.Components.DisclosureButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.disclosure_button/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          controls: "data-table"
        },
        slots: ["Data Table"]
      }
    ]
  end
end
