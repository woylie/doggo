defmodule Doggo.Components.Fab do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a floating action button.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.fab label="Add item" phx-click={JS.patch(to: "/items/new")}>
      <.icon><Heroicons.plus /></.icon>
    </.fab>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :buttons,
      since: "0.6.0",
      maturity: :developing,
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
        shape: [values: [nil, "circle", "pill"], default: "circle"]
      ]
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :label, :string, required: true
      attr :disabled, :boolean, default: false
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
      aria-label={@label}
      class={@class}
      disabled={@disabled}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
