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
    "components/property-list.css"
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
  def attrs_and_slots(_opts) do
    quote do
      slot :prop, required: true, doc: "A property to be rendered." do
        attr :label, :string, required: true

        attr :class, :any,
          doc: "Additional classes for the row that holds the term and value."
      end

      attr :rest, :global, doc: "Any additional HTML attributes."
    end
  end

  @impl true
  def init_block(opts, _extra) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      require Doggo

      Doggo.diagnostic do
        for prop <- var!(assigns).prop do
          Doggo.ensure_name!(prop[:label], unquote(name), "label")
        end
      end
    end
  end

  @impl true
  def template(_opts) do
    quote do
      ~H"""
      <dl
        :if={@prop != []}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        {@data_attrs}
        {@rest}
      >
        <div :for={prop <- @prop} {Doggo.class_attr(prop[:class])}>
          <dt>{prop.label}</dt>
          <dd>{render_slot(prop)}</dd>
        </div>
      </dl>
      """
    end
  end
end
