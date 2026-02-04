defmodule Doggo.Components.Switch do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a switch as a button.

    If you want to render a switch as part of a form, use the `input/1` component
    with the type `"switch"` instead.

    Note that this component only renders a button with a label, a state, and
    `<span>` with the class `switch-control`. You will need to style the switch
    control span with CSS in order to give it the appearance of a switch.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.switch
      label="Subscribe"
      checked={true}
      phx-click="toggle-subscription"
    />
    ```
    """
  end

  @impl true
  def config do
    [
      type: :buttons,
      since: "0.6.0",
      maturity: :experimental,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-control",
      "#{base_class}-label",
      "#{base_class}-state",
      "#{base_class}-state-off",
      "#{base_class}-state-on"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :label, :string, required: true
      attr :on_text, :string, default: "On"
      attr :off_text, :string, default: "Off"
      attr :checked, :boolean, default: false
      attr :rest, :global
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
      class={@class}
      type="button"
      role="switch"
      aria-checked={to_string(@checked)}
      {@data_attrs}
      {@rest}
    >
      <span class={"#{@base_class}-label"}>{@label}</span>
      <span class={"#{@base_class}-control"}><span></span></span>
      <span class={"#{@base_class}-state"}>
        <span
          class={
            if @checked,
              do: "#{@base_class}-state-on",
              else: "#{@base_class}-state-off"
          }
          aria-hidden="true"
        >
          <%= if @checked do %>
            {@on_text}
          <% else %>
            {@off_text}
          <% end %>
        </span>
      </span>
    </button>
    """
  end
end
