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

    If the inner block contains a link, add the `:contains_link` attribute:

    ```heex
    <p>
      Did you know that the
      <.tooltip id="labrador-info" contains_link>
        <.link navigate={~p"/labradors"}>Labrador Retriever</.link>
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
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :developing,
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
        If `false`, the component sets `tabindex="0"` on the element wrapping the
        inner block, so that the tooltip can be made visible by focusing the
        element.

        If the inner block already contains an element that is focusable, such as
        a link or a button, set this attribute to `true`.
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
      class={@class}
      aria-describedby={"#{@id}-tooltip"}
      data-aria-tooltip
      {@data_attrs}
      {@rest}
    >
      <span tabindex={!@contains_link && "0"}>
        {render_slot(@inner_block)}
      </span>
      <div role="tooltip" id={"#{@id}-tooltip"}>
        {render_slot(@tooltip)}
      </div>
    </span>
    """
  end
end
