defmodule Doggo.Components.MenuItemRadioGroup do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a group of menu item radios as part of a `menu/1` or `menu_bar/1`.

    See also `menu_button/1`, `menu_item/1`, and `menu_item_checkbox/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.menu id="actions-menu" labelledby="actions-button" hidden>
      <:item>
        <.menu_item_radio_group label="Theme">
          <:item on_click={JS.dispatch("switch-theme-light")}>
            Light
          </:item>
          <:item on_click={JS.dispatch("switch-theme-dark")} checked>
            Dark
          </:item>
        </.menu_item_radio_group>
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

      - Focus management
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
      attr :label, :string,
        required: true,
        doc: """
        A accessibility label for the group. Set as `aria-label` attribute.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :checked, :boolean
        attr :on_click, JS
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <ul class={@class} role="group" aria-label={@label} {@rest}>
      <li :for={item <- @item} role="none">
        <div
          role="menuitemradio"
          phx-click={item.on_click}
          aria-checked={to_string(item[:checked] || false)}
        >
          {render_slot(item)}
        </div>
      </li>
    </ul>
    """
  end
end
