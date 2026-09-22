defmodule Doggo.Storybook.SplitPane do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(opts) do
    function_name = Keyword.fetch!(opts, :name)

    [
      %Variation{
        id: :vertical,
        note:
          "The panes sit side by side. `Left` and `Right` move the separator.",
        attributes: %{
          id: "vertical-split-pane",
          orientation: :vertical,
          label: "Sidebar",
          default_size: 30,
          min_size: 10,
          max_size: 90
        },
        slots: [
          "<:primary>One</:primary>",
          "<:secondary>Two</:secondary>"
        ]
      },
      %Variation{
        id: :horizontal,
        note:
          "The panes sit above each other. `Up` and `Down` move the separator.",
        attributes: %{
          id: "horizontal-split-pane",
          orientation: :horizontal,
          label: "Sidebar",
          default_size: 50,
          min_size: 10,
          max_size: 90
        },
        slots: [
          "<:primary>One</:primary>",
          "<:secondary>Two</:secondary>"
        ]
      },
      %Variation{
        id: :nested,
        note: "Each split pane moves its own separator.",
        attributes: %{
          id: "nested-split-pane",
          orientation: :vertical,
          label: "Sidebar",
          default_size: 30
        },
        slots: [
          "<:primary>One</:primary>",
          """
          <:secondary>
            <.#{function_name}
              id="filter-splitter"
              label="Filters"
              orientation="horizontal"
              default_size={50}
            >
              <:primary>Two</:primary>
              <:secondary>Three</:secondary>
            </.#{function_name}>
          </:secondary>
          """
        ]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        orientation: :vertical,
        label: "Sidebar",
        default_size: 30
      },
      slots: [
        "<:primary>One</:primary>",
        "<:secondary>Two</:secondary>"
      ]
    }
  end
end
