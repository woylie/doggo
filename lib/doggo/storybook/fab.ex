defmodule Doggo.Storybook.Fab do
  @moduledoc false

  alias Doggo.Storybook.Shared
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:icon]

  def variations(opts) do
    [
      %Variation{
        id: :default,
        attributes: %{label: "Add item"},
        slots: slots(opts)
      },
      %Variation{
        id: :disabled,
        attributes: %{label: "Add item", disabled: true},
        slots: slots(opts)
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, opts) do
    %{
      attributes: %{label: "Add item"},
      slots: slots(opts)
    }
  end

  defp slots(opts) do
    [
      Shared.icon(:add, opts[:dependent_components])
    ]
  end
end
