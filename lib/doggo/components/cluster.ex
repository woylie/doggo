defmodule Doggo.Components.Cluster do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The cluster component is used to visually group child elements while
    applying a consistent gap between them.

    Common use cases are groups of buttons, groups of tags, or similar items.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.cluster>
      <div>some item</div>
      <div>some other item</div>
    </.cluster>
    ```
    """
  end

  @impl true
  def css_path do
    "layouts/_cluster.scss"
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :stable,
      modifiers: []
    ]
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
    <div role="group" class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
