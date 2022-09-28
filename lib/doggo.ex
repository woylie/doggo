defmodule Doggo do
  @moduledoc """
  Collection of Phoenix Components.
  """

  use Phoenix.Component

  ## Components

  @doc """
  Renders an icon from an SVG sprite.

  ## Examples

  Minimal example:

      <.icon name="arrow-left" />

  With assistive label:

      <.icon name="arrow-left" label={gettext("back")} />

  Specifiying the size:

      <.icon name="arrow-left" label={gettext("back")} size={:small} />

  With visible text:

      <.icon name="arrow-left" text={gettext("back")} />

  Icon right of the text:

      <.icon name="arrow-left" text={gettext("back")} icon_position={:right} />
  """
  @doc type: :component

  attr :name, :string, required: true, doc: "Icon name as used in the sprite."
  attr :class, :string, default: nil, doc: "Additional CSS classes."

  attr :size, :atom,
    default: :normal,
    doc: "Icon size (`:small`, `:normal`, `:medium`, `:large`)."

  attr :label, :string, default: nil, doc: "Assistive label."
  attr :text, :string, default: nil, doc: "Text to render next to the icon."

  attr :icon_position, :atom,
    default: :left,
    doc: "Position of the icon relative to the text (`:left`, `:right`)."

  attr :sprite_url, :string,
    default: "/assets/icons/sprite.svg",
    doc: "The URL of the SVG sprite."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def icon(assigns) do
    unless assigns.icon_position in [:left, :right] do
      raise """
      Invalid icon position

      Allowed values: :left, :right

      Got: #{inspect(assigns.icon_position)}
      """
    end

    ~H"""
    <span
      class={["icon", icon_size_class(@size), @class]}
      aria-label={@label}
      {@rest}
    >
      <%= if @text && @icon_position == :right do %>
        <span><%= @text %></span>
      <% end %>
      <svg aria-hidden="true"><use xlink:href={"#{@sprite_url}##{@name}"} /></svg>
      <%= if @text && @icon_position == :left do %>
        <span><%= @text %></span>
      <% end %>
    </span>
    """
  end

  defp icon_size_class(:medium), do: "is-medium"
  defp icon_size_class(:small), do: "is-small"
  defp icon_size_class(:large), do: "is-large"
  defp icon_size_class(:normal), do: nil

  defp icon_size_class(size) do
    raise """
    Invalid icon size

    Allowed sizes: :small, :normal, :medium, :large

    Got: #{inspect(size)}
    """
  end

  @doc """
  Renders a list of properties, i.e. key/value pairs.

  ## Example

      <.property_list>
        <:prop label={gettext("Name")}>George</:prop>
        <:prop label={gettext("Age")}>42</:prop>
      </.property_list>
  """
  @doc type: :component

  slot :prop, doc: "A property to be rendered." do
    attr :label, :string, required: true

    attr :show, :boolean,
      doc: "Set to `false` to hide the property. Defaults to `true`."
  end

  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Any additional HTML attributes."

  def property_list(assigns) do
    ~H"""
    <dl class={["property-list", @class]} {@rest}>
      <%= for prop <- @prop do %>
        <%= if Map.get(prop, :show, true) do %>
          <div>
            <dt><%= prop.label %></dt>
            <dd><%= render_slot(prop) %></dd>
          </div>
        <% end %>
      <% end %>
    </dl>
    """
  end

  ## Layouts

  @doc """
  Applies a vertical margin between the child elements.

  ## Example

      <.stack>
        <div>some block</div>
        <div>some other block</div>
      </.stack>

  To apply a vertical margin on nested elements as well, set `recursive` to
  `true`.

      <.stack recursive={true}>
        <div>
          <div>some nested block</div>
          <div>another nested block</div>
        </div>
        <div>some other block</div>
      </.stack>
  """
  @doc type: :layout

  slot :inner_block, required: true

  attr :recursive, :boolean,
    default: false,
    doc:
      "If `true`, the stack margins will be applied to nested elements as well."

  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Any additional HTML attributes."

  def stack(assigns) do
    ~H"""
    <div class={["stack", @class, if(@recursive, do: "is-recursive")]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
