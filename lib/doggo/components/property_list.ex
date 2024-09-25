defmodule Doggo.Components.PropertyList do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a list of properties as key/value pairs.

    This component is useful for displaying data in a structured format, such as
    a list of attributes for an entity. Each property is rendered as a `<dt>`
    element for the label and a `<dd>` element for the value.
    """
  end

  @impl true
  def usage do
    """
    Each property is specified using the `:prop` slot with a `label` attribute
    and an inner block.

    ```heex
    <.property_list>
      <:prop label={gettext("Name")}>George</:prop>
      <:prop label={gettext("Age")}>42</:prop>
    </.property_list>
    ```
    """
  end

  @impl true
  def css_path do
    "components/_property-list.scss"
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :stable,
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
      slot :prop, doc: "A property to be rendered." do
        attr :label, :string, required: true
      end

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <dl class={@class} {@rest}>
      <div :for={prop <- @prop}>
        <dt><%= prop.label %></dt>
        <dd><%= render_slot(prop) %></dd>
      </div>
    </dl>
    """
  end
end
