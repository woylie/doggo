defmodule Doggo.Storybook.Toolbar do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{id: "dog-toolbar-default", label: "Actions"},
        slots: slots(opts)
      },
      %Variation{
        id: :vertical,
        attributes: %{
          id: "dog-toolbar-vertical",
          label: "Actions",
          orientation: "vertical"
        },
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(id, _name, _value, opts) do
    %{
      attributes: %{id: id, label: "Actions"},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    control = fn event, label, icon_name ->
      """
      <button type="button" phx-click="#{event}" aria-label="#{label}">
        #{icon(icon_name, dependent_components)}
      </button>
      """
    end

    [
      """
      <div role="group">
        #{control.("feed-dog", "Feed", :pot)}
        #{control.("walk-dog", "Walk", :paw)}
      </div>
      <div role="group">
        #{control.("teach-trick", "Teach a trick", :teach)}
        #{control.("groom-dog", "Groom", :cut)}
      </div>
      """
    ]
  end
end
