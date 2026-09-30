defmodule Doggo.Components.Badge do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a badge, typically used for drawing attention to elements
    like notification counts.
    """
  end

  @impl true
  def usage(%{name: name}) do
    """
    ```heex
    <.#{name}>8</.#{name}>
    ```

    ## On a control

    A count on its own has no meaning. Add visually hidden text that to give it
    context. In the example below, the button's accessible name becomes
    "Messages 3 unread".

    ```heex
    <.button>
      <Heroicon.envelope />
      <span data-visually-hidden>Messages</span>
      <.#{name}>3<span data-visually-hidden> unread</span></.#{name}>
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
  def template(_opts) do
    quote do
      ~H"""
      <span
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        {@data_attrs}
        {@rest}
      >
        {render_slot(@inner_block)}
      </span>
      """
    end
  end
end
