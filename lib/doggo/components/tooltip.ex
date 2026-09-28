defmodule Doggo.Components.Tooltip do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders content with a tooltip.

    There are different ways to render a tooltip. This component renders a `<div>`
    with the `tooltip` role, which is hidden unless the element is hovered on or
    focused. For example CSS for this kind of tooltip, refer to
    [ARIA: tooltip role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/tooltip_role).

    A simpler alternative for styled text-only tooltips is to use a data attribute
    and the [`attr` CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/attr).
    Doggo does not provide a component for that kind of tooltip, since it is
    controlled by attributes only. You can check
    [Pico CSS](https://picocss.com/docs/tooltip) for an example implementation.
    """
  end

  @impl true
  def usage do
    """
    A tooltip describes a control that already has a purpose of its own, such
    as an icon button. Render the control in the inner block and spread the
    attributes it receives on it, which point `aria-describedby` at the
    tooltip:

    ```heex
    <.tooltip id="delete-info" :let={trigger}>
      <.button phx-click="delete" {trigger}>Delete</.button>
      <:tooltip>Deletes the row and its history.</:tooltip>
    </.tooltip>
    ```

    If the control already has a description, list both ids in one
    `aria-describedby`, since a second attribute of the same name is ignored:

    ```heex
    <.tooltip id="delete-info" :let={trigger}>
      <.button
        phx-click="delete"
        aria-describedby={"delete-hint " <> trigger["aria-describedby"]}
      >
        Delete
      </.button>
      <:tooltip>Deletes the row and its history.</:tooltip>
    </.tooltip>
    ```

    Do not use a tooltip to explain text or to hide information behind an
    info icon. The tooltip is announced when the control is focused, and a
    control that exists only to show it does nothing when it is pressed. Put
    the information in visible text instead.

    This component needs the `Doggo.Tooltip` JavaScript hook for `Esc` to
    dismiss the tooltip. See
    [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.

    Your stylesheet decides when the tooltip is visible. Show it on `:hover` and
    `:focus-within`, and hide it when the root element has the `data-dismissed`
    attribute, which the hook sets. See the example CSS.
    """
  end

  @impl true
  def keyboard do
    """
    - `Tab` - focus the control, which shows the tooltip.
    - `Esc` - hide the tooltip while it is shown, without moving the focus.
    """
  end

  @impl true
  def css_path do
    "components/tooltip.css"
  end

  @impl true
  def config do
    [
      type: :feedback,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      **The markup may change.** A rewrite on top of the Popover API is being
      considered, which would put the tooltip in the top layer, so that an
      ancestor with `overflow: hidden` can no longer clip it. That would change
      the elements this component emits and the attributes your stylesheet
      targets.
      """,
      base_class: "tooltip-container",
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block,
        required: true,
        doc: """
        The control the tooltip describes. The inner block receives the
        attributes to spread on it, which point `aria-describedby` at the
        tooltip. If the control has a description of its own, list both ids
        in one attribute instead of spreading:
        `aria-describedby={"hint " <> trigger["aria-describedby"]}`.
        """

      slot :tooltip, required: true
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <span
      id={@id}
      class={@class}
      data-aria-tooltip
      phx-hook="Doggo.Tooltip"
      {@data_attrs}
      {@rest}
    >
      {render_slot(@inner_block, %{"aria-describedby" => "#{@id}-tooltip"})}
      <div role="tooltip" id={"#{@id}-tooltip"}>
        {render_slot(@tooltip)}
      </div>
    </span>
    """
  end
end
