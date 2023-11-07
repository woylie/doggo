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
      <div class="dg-alert-icon"><.icon name={alert_icon(@level)} /></div>
      <div class="dg-alert-body">
        <div :if={@title != []} class="dg-alert-title">
          <%= render_slot(@title) %>
        </div>
        <div class="dg-alert-message"><%= render_slot(@inner_block) %></div>
      </div>
      <button
        :if={@show_close_button}
        on_click={maybe_clear_flash(@clear_flash, @level) |> JS.hide(to: "##{@id}")}
        aria-label={@close_button_label}
        class="dg-alert-close"
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
    ~H"""
    <span
      class={["icon", icon_size_class(@size), @class]}
      aria-label={@label}
      {@rest}
    >
      <span :if={@text && @icon_position == :right}><%= @text %></span>
      <svg aria-hidden="true"><use xlink:href={"#{@sprite_url}##{@name}"} /></svg>
      <span :if={@text && @icon_position == :left}><%= @text %></span>
    </span>
    """
  end

  defp icon_size_class(:medium), do: "is-medium"
  defp icon_size_class(:small), do: "is-small"
  defp icon_size_class(:large), do: "is-large"
  defp icon_size_class(:normal), do: "is-normal"

  @doc """
  Renders a modal.

  ## Usage

  There are two primary ways to manage the display of the modal: via URL state
  or by setting and removing the `open` attribute.

  ### With URL

  To toggle the modal visibility based on the URL:

  1. Use the `:if` attribute to conditionally render the modal when a specific
     live action matches.
  2. Set the `on_cancel` attribute to patch back to the original URL when the
     user chooses to close the modal.
  3. Set the `open` attribute to declare the modal's initial visibility state.

  #### Example

      <.modal
        :if={@live_action == :show}
        id="pet-modal"
        on_cancel={JS.patch(~p"/pets")}
        open
      >
        <:title>Show pet</:title>
        <p>My pet is called Johnny.</p>
        <:footer>
          <.link phx-click={JS.exec("data-cancel", to: "#pet-modal")}>
            Close
          </.link>
        </:footer>
      </.modal>

  To open the modal, patch or navigate to the URL associated with the live
  action.

      <.link patch={~p"/pets/\#{@id}"}>show</.link>

  ### Without URL

  To toggle the modal visibility dynamically with the `open` attribute:

  1. Omit the `open` attribute in the template.
  2. Use the `show_modal` and `hide_modal` functions to change the visibility.

  #### Example

      <.modal id="pet-modal">
        <:title>Show pet</:title>
        <p>My pet is called Johnny.</p>
        <:footer>
          <.link phx-click={JS.exec("data-cancel", to: "#pet-modal")}>
            Close
          </.link>
        </:footer>
      </.modal>

  To open modal, use the `show_modal` function.

      <.link phx-click={show_modal("pet-modal")}>show</.link>

  ## CSS

  To hide the modal when the `open` attribute is not set, use the following CSS
  styles:

      dialog.dg-modal:not([open]),
      dialog.dg-modal[open="false"] {
        display: none;
      }

  ## Semantics

  While the `showModal()` JavaScript function is typically recommended for
  managing modal dialog semantics, this component utilizes the `open` attribute
  to control visibility. This approach is chosen to eliminate the need for
  library consumers to add additional JavaScript code. To ensure proper
  modal semantics, the `aria-modal` attribute is added to the dialog element.

  """

  attr :id, :string, required: true
  attr :open, :boolean, default: false, doc: "Initializes the modal as open."
  attr :on_cancel, JS, default: %JS{}

  slot :title, required: true
  slot :inner_block, required: true, doc: "The modal body."

  slot :close,
    doc: "The content for the 'close' link. Defaults to the word 'close'."

  slot :footer

  def modal(assigns) do
    ~H"""
    <dialog
      id={@id}
      class="dg-modal"
      aria-modal={(@open && "true") || "false"}
      aria-labelledby={"#{@id}-title"}
      open={@open}
      phx-mounted={@open && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
    >
      <.focus_wrap
        id={"#{@id}-container"}
        class="dg-modal-container"
        phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
        phx-key="escape"
        phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
      >
        <article>
          <header>
            <.link
              href="#"
              class="dg-modal-close"
              aria-label="Close"
              phx-click={JS.exec("data-cancel", to: "##{@id}")}
            >
              <%= render_slot(@close) %>
              <span :if={@close == []}>close</span>
            </.link>
            <h2 id={"#{@id}-title"}><%= render_slot(@title) %></h2>
          </header>
          <div id={"#{@id}-content"} class="dg-modal-content">
            <%= render_slot(@inner_block) %>
          </div>
          <footer :if={@footer != []}>
            <%= render_slot(@footer) %>
          </footer>
        </article>
      </.focus_wrap>
    </dialog>
    """
  end

  @doc """
  Shows the modal with the given ID.

  ## Example

      <.link phx-click={show_modal("pet-modal")}>show</.link>
  """
  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.set_attribute({"open", "true"}, to: "##{id}")
    |> JS.set_attribute({"aria-modal", "true"}, to: "##{id}")
    |> JS.focus_first(to: "##{id}-content")
  end

  @doc """
  Hides the modal with the given ID.

  ## Example

      <.link phx-click={hide_modal("pet-modal")}>hide</.link>
  """
  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.remove_attribute("open", to: "##{id}")
    |> JS.set_attribute({"aria-modal", "false"}, to: "##{id}")
    |> JS.pop_focus()
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
  end

  attr :class, :string, default: nil, doc: "Additional CSS classes."
  attr :rest, :global, doc: "Any additional HTML attributes."

  def property_list(assigns) do
    ~H"""
    <dl class={["dg-property-list", @class]} {@rest}>
      <div :for={prop <- @prop}>
        <dt><%= prop.label %></dt>
        <dd><%= render_slot(prop) %></dd>
      </div>
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
