defmodule Doggo.Storybook.SplitPane do
  @moduledoc false
  alias PhoenixStorybook.Stories.Variation

  def variations(opts) do
    function_name = Keyword.fetch!(opts, :name)

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
            <.#{function_name}
              id="filter-splitter"
              label="Filters"
              orientation="vertical"
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
        orientation: :horizontal,
        label: "Sidebar",
        default_size: 100
      },
      slots: [
        "<:primary>One</:primary>",
        "<:secondary>Two</:secondary>"
      ]
    }
  end
end
