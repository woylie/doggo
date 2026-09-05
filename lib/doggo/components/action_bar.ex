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

    This component needs the `Doggo.Toolbar` JavaScript hook. See
    [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.
    """
  end

  @impl true
  def keyboard do
    """
    - `Left` and `Right` - move between the buttons, wrapping at the ends.
    - `Home` and `End` - first and last button.
    - `Enter` or `Space` - run the focused button's `on_click`.

    The action bar is a single tab stop. `Tab` moves to the button the user last
    used, and the arrow keys move between them.
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
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
      attr :id, :string,
        required: true,
        doc: "A unique DOM ID. Required for the JavaScript hook."

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item,
        required: true,
        doc: """
        An action. The content can be an icon, an icon with text, or text.

        `label` is the button's accessible name, rendered as `aria-label` and as
        the tooltip, so an icon-only item is named without the caller doing
        anything further.

        Where the content includes visible text, `label` must contain that text,
        since `aria-label` overrides the content. Voice control users activate a
        button by speaking the name they can see, so a button reading "Delete"
        with `label="Remove record"` cannot be activated by voice.
        """ do
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
    <div
      id={@id}
      role="toolbar"
      class={@class}
      phx-hook="Doggo.Toolbar"
      {@data_attrs}
      {@rest}
    >
      <button
        :for={item <- @item}
        type="button"
        phx-click={item.on_click}
        aria-label={item.label}
        title={item.label}
      >
        {render_slot(item)}
      </button>
    </div>
    """
  end
end
