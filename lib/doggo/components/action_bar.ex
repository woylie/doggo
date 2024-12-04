defmodule Doggo.Components.ActionBar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The action bar offers users quick access to primary actions within the
    application.

    It is typically positioned to float above other content.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.action_bar>
      <:item label="Edit" on_click={JS.push("edit")}>
        <.icon><Lucideicons.pencil aria-hidden /></.icon>
      </:item>
      <:item label="Move" on_click={JS.push("move")}>
        <.icon><Lucideicons.move aria-hidden /></.icon>
      </:item>
      <:item label="Archive" on_click={JS.push("archive")}>
        <.icon><Lucideicons.archive aria-hidden /></.icon>
      </:item>
    </.action_bar>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Roving tabindex
      - Move focus with arrow keys
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
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :label, :string, required: true
        attr :on_click, JS, required: true
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
    <div role="toolbar" class={@class} {@rest}>
      <button :for={item <- @item} phx-click={item.on_click} title={item.label}>
        {render_slot(item)}
      </button>
    </div>
    """
  end
end
