defmodule Storybook.Components.SplitPane do
  use PhoenixStorybook.Story, :component

  def function, do: &Doggo.split_pane/1

  def variations do
    [
      %Variation{
        id: :horizontal,
        attributes: %{
          id: "horizontal-split-pane",
          orientation: :horizontal,
          label: "Sidebar",
          default_size: 100
        },
        slots: [
          "<:primary>One</:primary>",
          "<:secondary>Two</:secondary>"
        ]
      },
      %Variation{
        id: :vertical,
        attributes: %{
          id: "vertical-split-pane",
          orientation: :vertical,
          label: "Sidebar",
          default_size: 100
        },
        slots: [
          "<:primary>One</:primary>",
          "<:secondary>Two</:secondary>"
        ]
      },
      %Variation{
        id: :nested,
        attributes: %{
          id: "nested-split-pane",
          orientation: :horizontal,
          label: "Sidebar",
          default_size: 100
        },
        slots: [
          "<:primary>One</:primary>",
          """
          <:secondary>
            <Doggo.split_pane
              id="filter-splitter"
              label="Filters"
              orientation="vertical"
              default_size={50}
            >
              <:primary>Two</:primary>
              <:secondary>Three</:secondary>
            </Doggo.split_pane>
          </:secondary>
          """
        ]
      }
    ]
  end
end
