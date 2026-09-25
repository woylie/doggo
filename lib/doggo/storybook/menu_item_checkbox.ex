defmodule Doggo.Storybook.MenuItemCheckbox do
  @moduledoc false

  alias Phoenix.LiveView.JS
  alias PhoenixStorybook.Stories.Variation

  def dependent_components, do: [:menu]

  def template(opts) do
    dependent_components = opts[:dependent_components]
    menu_fun = dependent_components[:menu]

    if menu_fun do
      """
      <.#{menu_fun} id="menu-:variation_id" label="Actions">
        <:item>
          <.psb-variation/>
        </:item>
      </.#{menu_fun}>
      """
    else
      """
      <p>Please compile the <code>menu</code> component to see a complete preview.</p>
      """
    end
  end

  def variations(_opts) do
    [
      %Variation{
        id: :default,
        attributes: %{
          on_click: JS.toggle_attribute({"aria-checked", "true", "false"})
        },
        slots: ["Word wrap"]
      },
      %Variation{
        id: :checked,
        attributes: %{
          checked: true,
          on_click: JS.toggle_attribute({"aria-checked", "true", "false"})
        },
        slots: ["Word wrap"]
      },
      %Variation{
        id: :indeterminate,
        note:
          "`checked={:indeterminate}` is for an item that stands for a group of items of which only some are checked. Clicking it here checks it, and later clicks toggle it.",
        attributes: %{
          checked: :indeterminate,
          on_click: JS.toggle_attribute({"aria-checked", "true", "false"})
        },
        slots: ["All notifications"]
      }
    ]
  end

  def modifier_variation_base(_id, _name, _value, _opts) do
    %{
      attributes: %{
        on_click: JS.toggle_attribute({"aria-checked", "true", "false"})
      },
      slots: ["Word wrap"]
    }
  end
end
