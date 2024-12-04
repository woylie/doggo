defmodule Doggo.Components.DisclosureButton do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a button that toggles the visibility of another element.

    Use this component to reveal or hide additional content, such as in
    collapsible sections or dropdown menus.

    For a button that toggles other states, use `toggle_button/1` instead. See
    also `button/1` and `button_link/1`.
    """
  end

  @impl true
  def usage do
    """
    Set the `controls` attribute to the DOM ID of the element that you want to
    toggle with the button.

    The initial state is hidden. Do not forget to add the `hidden` attribute to
    the toggled element. Otherwise, visibility of the element will not align with
    the `aria-expanded` attribute of the button.

    ```heex
    <.disclosure_button controls="data-table">
      Data Table
    </.disclosure_button>

    <table id="data-table" hidden></table>
    ```

    ### CSS

    To select disclosure buttons without class names and to apply styles
    depending on the state (e.g. to render a caret), you can use the
    `aria-controls` and `aria-expanded` attributes.

    ```css
    button[aria-controls][aria-expanded] {
      /* Base styles for disclosure buttons */
    }

    button[aria-controls][aria-expanded="true"] {
      /* Styles when content is visible */
    }
    ```
    """
  end

  @impl true
  def css_path do
    "components/_button.scss"
  end

  @impl true
  def config do
    [
      type: :buttons,
      since: "0.6.0",
      maturity: :refining,
      base_class: "button",
      modifiers: [
        variant: [
          values: [
            "primary",
            "secondary",
            "info",
            "success",
            "warning",
            "danger"
          ],
          default: "primary"
        ]
      ]
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :controls, :string,
        required: true,
        doc: """
        The DOM ID of the element that this button controls.
        """

      attr :rest, :global, include: ~w(autofocus form name value)

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
      type="button"
      aria-expanded="false"
      aria-controls={@controls}
      phx-click={Doggo.toggle_disclosure(@controls)}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
