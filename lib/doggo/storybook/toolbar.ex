defmodule Doggo.Storybook.Toolbar do
  @moduledoc false

  import Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:button, :icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Actions"},
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Actions"},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    dependent_components = opts[:dependent_components]

    button_function =
      if fun = dependent_components[:button] do
        ".#{fun}"
      else
        "button"
      end

    [
      """
      <div role="group">
        <#{button_function} phx-click="feed-dog">
          #{icon(:pot, dependent_components)}
        </#{button_function}>
        <#{button_function} phx-click="walk-dog">
          #{icon(:paw, dependent_components)}
        </#{button_function}>
      </div>
      <div role="group">
        <#{button_function} phx-click="teach-trick">
          #{icon(:teach, dependent_components)}
        </#{button_function}>
        <#{button_function} phx-click="groom-dog">
          #{icon(:cut, dependent_components)}
        </#{button_function}>
      </div>
      """
    ]
  end
end
