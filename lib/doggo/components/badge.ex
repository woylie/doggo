defmodule Doggo.Components.Badge do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Generates a badge component, typically used for drawing attention to elements
    like notification counts.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.badge>8</.badge>
    ```

    ## On a control

    A count on its own has no meaning. Add visually hidden text that to give it
    context. In the example below, the button's accessible name becomes
    "Messages 3 unread".

    ```heex
    <.button>
      <Heroicon.envelope />
      <span data-visually-hidden>Messages</span>
      <.badge>3<span data-visually-hidden> unread</span></.badge>
    </.button>
    ```

    You can place the badge into the corner of the control with CSS.

    ```css
    :is(a, button, summary, [role="tab"], [role="menuitem"]):has(> .badge) {
      position: relative;
    }

    :is(a, button, summary, [role="tab"], [role="menuitem"]) > .badge {
      position: absolute;
      inset-block-start: 0;
      inset-inline-end: 0;
      margin-block-start: var(--badge-overlap);
      margin-inline-end: var(--badge-overlap);
    }
    ```
    """
  end

  @impl true
  def css_path do
    "components/badge.css"
  end

  @impl true
  def config do
    [
      type: :feedback,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [
        size: [
          values: ["small", "normal", "medium", "large"],
          default: "normal"
        ],
        variant: [
          values: [
            nil,
            "primary",
            "secondary",
            "info",
            "success",
            "warning",
            "danger"
          ],
          default: nil
        ]
      ]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :rest, :global, doc: "Any additional HTML attributes."
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
    <span class={@class} {@data_attrs} {@rest}>
      {render_slot(@inner_block)}
    </span>
    """
  end
end
