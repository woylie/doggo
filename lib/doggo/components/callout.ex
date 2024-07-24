defmodule Doggo.Components.Callout do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Use the callout to highlight supplementary information related to the main
    content.

    For information that needs immediate attention of the user, use `alert/1`
    instead.
    """
  end

  @impl true
  def usage do
    """
    Standard callout:

    ```heex
    <.callout title="Dog Care Tip">
      <p>Regular exercise is essential for keeping your dog healthy and happy.</p>
    </.callout>
    ```

    Callout with an icon:

    ```heex
    <.callout title="Fun Dog Fact">
      <:icon><Heroicons.information_circle /></:icon>
      <p>
        Did you know? Dogs have a sense of time and can get upset when their
        routine is changed.
      </p>
    </.callout>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :developing,
      modifiers: [
        variant: [
          values: [
            "info",
            "success",
            "warning",
            "danger"
          ],
          default: "info"
        ]
      ]
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true
      attr :title, :string, default: nil, doc: "An optional title."
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block, required: true, doc: "The main content of the alert."
      slot :icon, doc: "Optional slot to render an icon."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <aside
      id={@id}
      class={@class}
      aria-labelledby={@title && "#{@id}-title"}
      {@rest}
    >
      <div :if={@icon != []} class={"#{@base_class}-icon"}>
        <%= render_slot(@icon) %>
      </div>
      <div class={"#{@base_class}-body"}>
        <div :if={@title} id={"#{@id}-title"} class={"#{@base_class}-title"}>
          <%= @title %>
        </div>
        <div class={"#{@base_class}-message"}>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </aside>
    """
  end
end
