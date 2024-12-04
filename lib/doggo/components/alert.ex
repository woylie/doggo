defmodule Doggo.Components.Alert do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The alert component serves as a notification mechanism to provide feedback to
    the user.

    For supplementary information that doesn't require the user's immediate
    attention, use `callout/1` instead.
    """
  end

  @impl true
  def usage do
    """
    Minimal example:

    ```heex
    <.alert id="some-alert"></.alert>
    ```

    With title, icon and level:

    ```heex
    <.alert id="some-alert" level={:info} title="Info">
      message
      <:icon><Heroicon.light_bulb /></:icon>
    </.alert>
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
        level: [
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
  def nested_classes(base_class) do
    [
      "#{base_class}-icon",
      "#{base_class}-body",
      "#{base_class}-title",
      "#{base_class}-message"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :title, :string, default: nil, doc: "An optional title."

      attr :on_close, :any,
        default: nil,
        doc: """
        JS command to run when the close button is clicked. If not set, no close
        button is rendered.
        """

      attr :close_label, :any,
        default: "close",
        doc: """
        This value will be used as aria label. Consider overriding it in case your
        app is served in different languages.
        """

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
    <div
      phx-click={@on_close}
      id={@id}
      role="alert"
      aria-labelledby={@title && "#{@id}-title"}
      class={@class}
      {@rest}
    >
      <div :if={@icon != []} class={"#{@base_class}-icon"}>
        {render_slot(@icon)}
      </div>
      <div class={"#{@base_class}-body"}>
        <div :if={@title} id={"#{@id}-title"} class={"#{@base_class}-title"}>
          {@title}
        </div>
        <div class={"#{@base_class}-message"}>{render_slot(@inner_block)}</div>
      </div>
      <button :if={@on_close} phx-click={@on_close}>
        {@close_label}
      </button>
    </div>
    """
  end
end
