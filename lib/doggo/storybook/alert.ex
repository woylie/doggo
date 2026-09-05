defmodule Doggo.Storybook.Alert do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: slots()
      },
      %Variation{
        id: :title,
        attributes: %{title: "This is the title."},
        slots: slots()
      },
      %Variation{
        id: :icon,
        attributes: %{title: "This is the title."},
        slots: slots_with_icon(opts)
      },
      %Variation{
        id: :close_button,
        attributes: %{
          on_close: {:eval, ~s|JS.hide(to: "#alert-single-close-button")|}
        },
        slots: slots()
      },
      %Variation{
        id: :close_button_with_icon,
        attributes: %{
          close_label: "Dismiss",
          on_close:
            {:eval, ~s|JS.hide(to: "#alert-single-close-button-with-icon")|}
        },
        slots: slots_with_close(opts)
      }
    ]
  end

  def modifier_variation_base(_id, name, value, _opts) do
    %{
      slots: ["This is an alert with #{name}: #{value}."]
    }
  end

  defp slots do
    ["This is an alert."]
  end

  defp slots_with_close(opts) do
    dependent_components = opts[:dependent_components]

    [
      "This is an alert.",
      "<:close>#{icon(:close, dependent_components)}</:close>"
    ]
  end

  defp slots_with_icon(opts) do
    dependent_components = opts[:dependent_components]

    [
      "This is an alert.",
      "<:icon>#{icon(:info, dependent_components)}</:icon>"
    ]
  end
end
