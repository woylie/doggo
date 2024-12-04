defmodule Doggo.Components.Button do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a button.

    Use this component when you need to perform an action such as submitting a
    form, confirming an action, deleting an item, toggling a setting, etc.

    If you need to navigate to a different page or a specific section on the
    current page and want to style the link like a button, use `button_link/1`
    instead.

    See also `button_link/1`, `toggle_button/1`, and `disclosure_button/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.button>Confirm</.button>

    <.button type="submit">
      Submit
    </.button>
    ```

    To indicate a loading state, for example when submitting a form, use the
    `aria-busy` attribute:

    ```heex
    <.button aria-label="Saving..." aria-busy>
      click me
    </.button>
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
      base_class: "button",
      type: :buttons,
      since: "0.6.0",
      maturity: :stable,
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
      attr :type, :string,
        values: ["button", "reset", "submit"],
        default: "button"

      attr :disabled, :boolean, default: nil
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
    <button type={@type} class={@class} disabled={@disabled} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end
end
