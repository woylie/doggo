defmodule Doggo.Components.MenuItem do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a button that acts as a menu item within a `menu/1` or `menu_bar/1`.

    A menu item is meant to be used to trigger an action. For a button that
    toggles the visibility of a menu, use `menu_button/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.menu label="Actions">
      <:item>
        <.menu_item on_click={JS.dispatch("myapp:copy")}>
          Copy
        </.menu_item>
      </:item>
      <:item>
        <.menu_item on_click={JS.dispatch("myapp:paste")}>
          Paste
        </.menu_item>
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
  def render(assigns) do
    ~H"""
    <button
      class={@class}
      type="button"
      role="menuitem"
      phx-click={@on_click}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
