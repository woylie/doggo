defmodule Doggo do
  @moduledoc """
  Collection of Phoenix Components.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  ## Components

  @doc """
  The alert component serves as a notification mechanism to provide feedback to
  the user.
  """
  attr :id, :string, required: true

  attr :level, :atom,
    values: [:info, :success, :warning, :error],
    default: :info,
    doc: "Semantic level of the alert."

  attr :show_close_button, :boolean, default: true

  attr :close_button_label, :string,
    default: "close",
    doc: """
    This value will be used as aria label. Consider overriding it in case your
    app is served in different languages.
    """

  attr :clear_flash, :boolean,
    default: false,
    doc: """
    If you use this component to render flash messages, set this attribute to
    `true` in order to clear them when clicking the close button.
    """

  slot :title, default: nil, doc: "An optional title."
  slot :inner_block, required: true, doc: "The main content of the alert."

  def alert(assigns) do
    ~H"""
    <div id={@id} role="alert" class={["alert", alert_level_class(@level)]}>
      <div class="alert-icon"><.icon name={alert_icon(@level)} /></div>
      <div class="alert-body">
        <div :if={@title != []} class="alert-title">
          <%= render_slot(@title) %>
        </div>
        <div class="alert-message"><%= render_slot(@inner_block) %></div>
      </div>
      <button
        :if={@show_close_button}
        on_click={maybe_clear_flash(@clear_flash, @level) |> JS.hide(to: "##{@id}")}
        aria-label={@close_button_label}
        class="alert-close"
      >
        <.icon name="x" />
      </button>
    </div>
    """
  end

  defp alert_level_class(:info), do: "is-info"
  defp alert_level_class(:success), do: "is-success"
  defp alert_level_class(:warning), do: "is-warning"
  defp alert_level_class(:error), do: "is-error"

  defp alert_icon(:info), do: "info"
  defp alert_icon(:success), do: "check-circle"
  defp alert_icon(:warning), do: "alert-circle"
  defp alert_icon(:error), do: "x-octagon"

  defp maybe_clear_flash(true, level) do
    JS.push("lv:clear-flash", value: %{key: level})
  end

  defp maybe_clear_flash(false, _), do: %JS{}

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
    values: [:small, :normal, :medium, :large]

  attr :label, :string, default: nil, doc: "Assistive label."
  attr :text, :string, default: nil, doc: "Text to render next to the icon."

  attr :icon_position, :atom,
    default: :left,
    values: [:left, :right],
    doc: "Position of the icon relative to the text."

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
