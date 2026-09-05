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
    With an inline text:

    ```heex
    <p>
      Did you know that the
      <.tooltip id="labrador-info">
        Labrador Retriever
        <:tooltip>
          <p><strong>Labrador Retriever</strong></p>
          <p>
            Labradors are known for their friendly nature and excellent
            swimming abilities.
          </p>
        </:tooltip>
      </.tooltip>
      is one of the most popular dog breeds in the world?
    </p>
    ```

    If the inner block contains a link or another focusable element, add the
    `contains_link` attribute and put `aria-describedby` on that element. Its
    value is the `id` of the component with `-tooltip` appended:

    ```heex
    <p>
      Did you know that the
      <.tooltip id="labrador-info" contains_link>
        <.link navigate={~p"/labradors"} aria-describedby="labrador-info-tooltip">
          Labrador Retriever
        </.link>
        <:tooltip>
          <p><strong>Labrador Retriever</strong></p>
          <p>
            Labradors are known for their friendly nature and excellent
            swimming abilities.
          </p>
        </:tooltip>
      </.tooltip>
      is one of the most popular dog breeds in the world?
    </p>
    ```

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
    - `Tab` - focus the described element, which shows the tooltip.
    - `Esc` - hide the tooltip while it is shown, without moving the focus.
    """
  end

  @impl true
  def css_path do
    "components/_tooltip.scss"
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
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
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :contains_link, :boolean,
        default: false,
        doc: """
        If `false`, the component sets `tabindex="0"` and `aria-describedby` on
        the element wrapping the inner block, so that the tooltip is announced
        and can be made visible by focusing that element.

        Set this to `true` if the inner block already contains a focusable
        element, such as a link or a button. The component then sets neither
        `tabindex` nor `aria-describedby`, because both belong on the element
        that receives the focus, and you render that element.

        Set `aria-describedby` on it yourself. Its value is the `id` you passed
        with `-tooltip` appended: a tooltip with `id="labrador-info"` needs
        `aria-describedby="labrador-info-tooltip"`. See the usage example.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block, required: true
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
      <span
        tabindex={!@contains_link && "0"}
        aria-describedby={!@contains_link && "#{@id}-tooltip"}
      >
        {render_slot(@inner_block)}
      </span>
      <div role="tooltip" id={"#{@id}-tooltip"}>
        {render_slot(@tooltip)}
      </div>
    </span>
    """
  end
end
