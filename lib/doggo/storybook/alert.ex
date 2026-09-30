defmodule Doggo.Storybook.Alert do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon, :button]

  def template do
    """
    <div style="inline-size: 100%">
      <.psb-variation/>
    </div>
    """
  end

  def modifier_variation_group_template(_name, _opts) do
    """
    <div style="display: grid; gap: 0.75rem; inline-size: 100%">
      <.psb-variation-group/>
    </div>
    """
  end

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: slots()
      },
      %Variation{
        id: :title,
        attributes: %{},
        slots: ["<:title>This is the title.</:title>" | slots()]
      },
      %Variation{
        id: :icon,
        attributes: %{},
        slots: ["<:title>This is the title.</:title>" | slots_with_icon(opts)]
      },
      %Variation{
        id: :close_button,
        attributes: %{
          on_close: {:eval, ~s|JS.hide(to: "#alert-single-close-button")|}
        },
        slots: slots()
      },
      %Variation{
        id: :action,
        attributes: %{},
        slots: ["<:title>Session expired</:title>" | slots_with_action(opts)]
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

  defp slots_with_action(opts) do
    [
      "Your session has expired. Sign in again to continue.",
      "<:action>#{button("Sign in", ~s|type="button"|, opts[:dependent_components])}</:action>"
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
