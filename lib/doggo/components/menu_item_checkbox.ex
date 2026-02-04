defmodule Doggo.Components.MenuItemCheckbox do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a menu item checkbox as part of a `menu/1` or `menu_bar/1`.

    See also `menu_item/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.menu label="Actions">
      <:item>
        <.menu_item_checkbox on_click={JS.dispatch("myapp:toggle-word-wrap")}>
          Word wrap
        </.menu_item_checkbox>
      </:item>
    </.menu>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :menu,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - State management
      - Keyboard support
      """,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :checked, :boolean, default: false
      attr :on_click, Phoenix.LiveView.JS, required: true
      attr :rest, :global

      slot :inner_block, required: true
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(%{checked: checked} = assigns) do
    assigns = assign(assigns, :checked, to_string(checked))

    ~H"""
    <div
      class={@class}
      role="menuitemcheckbox"
      aria-checked={@checked}
      phx-click={@on_click}
      {@data_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
