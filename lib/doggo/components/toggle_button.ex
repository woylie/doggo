defmodule Doggo.Components.ToggleButton do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a button that toggles a state.

    Use this component to switch a feature or setting on or off, for example to
    toggle dark mode or mute/unmute sound.

    See also `button/1`, `button_link/1`, and `disclosure_button/1`.
    """
  end

  @impl true
  def usage do
    """
    With a `Phoenix.LiveView.JS` command:

    ```heex
    <.toggle_button on_click={JS.push("toggle-mute")} pressed={@muted}>
      Mute
    </.toggle_button>
    ```

    ## Accessibility

    The button state is conveyed via the `aria-pressed` attribute and the button
    styling. The button text should not change depending on the state. You may
    however include an icon that changes depending on the state.

    ## CSS

    A toggle button can be identified with an attribute selector for the
    `aria-pressed` attribute.

    ```css
    // any toggle button regardless of state
    button[aria-pressed] {}

    // unpressed toggle buttons
    button[aria-pressed="false"] {}

    // pressed toggle buttons
    button[aria-pressed="true"] {}
    ```
    """
  end

  @impl true
  def config do
    [
      type: :buttons,
      since: "0.6.0",
      maturity: :developing,
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
        ],
        size: [
          values: ["small", "normal", "medium", "large"],
          default: "normal"
        ],
        fill: [values: ["solid", "outline", "text"], default: "solid"],
        shape: [values: [nil, "circle", "pill"], default: nil]
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
      attr :pressed, :boolean, default: false

      attr :on_click, Phoenix.LiveView.JS,
        required: true,
        doc: """
        `Phoenix.LiveView.JS` command or event name to trigger when the button is
        clicked.
        """

      attr :disabled, :boolean, default: nil
      attr :rest, :global

      slot :inner_block, required: true
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(%{pressed: pressed} = assigns) do
    assigns = assign(assigns, :pressed, to_string(pressed))

    ~H"""
    <button
      type="button"
      phx-click={
        Phoenix.LiveView.JS.toggle_attribute(
          @on_click,
          {"aria-pressed", "true", "false"}
        )
      }
      aria-pressed={@pressed}
      class={@class}
      disabled={@disabled}
      {@data_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
