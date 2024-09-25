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
    """
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
  def attrs_and_slots do
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
    <span class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
