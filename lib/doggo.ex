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
  @doc type: :component

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
      <div class="alert-icon">
        <.icon_sprite name={alert_icon(@level)} />
      </div>
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
        <.icon_sprite name="x" />
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
  Renders a card in an `article` tag, typically used repetitively in a grid or
  flex box layout.

  ## Usage

      <Doggo.card>
        <:image>
          <img src="image.png" alt="Picture of a dog dressed in a poncho." />
        </:image>
        <:header><h2>Dog Fashion Show</h2></:header>
        <:main>
          The next dog fashion show is coming up quickly. Here's what you need
          to look out for.
        </:main>
        <:footer>
          <span>2023-11-15 12:24</span>
          <span>Events</span>
        </:footer>
      </Doggo.card>
  """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :image,
    doc: """
    An optional image slot. The slot content will be rendered within a figure
    element.
    """

  slot :header,
    doc: """
    The header of the card. You typically want to wrap the header in a `h2` or
    `h3` tag, or another header level, depending on the hierarchy on the page.
    """

  slot :main, doc: "The main content of the card."

  slot :footer,
    doc: """
    A footer of the card, typically containing controls, tags, or meta
    information.
    """

  def card(assigns) do
    ~H"""
    <article class={["card" | List.wrap(@class)]} {@rest}>
      <figure :if={@image != []}><%= render_slot(@image) %></figure>
      <header :if={@header != []}><%= render_slot(@header) %></header>
      <main :if={@main != []}><%= render_slot(@main) %></main>
      <footer :if={@footer != []}><%= render_slot(@footer) %></footer>
    </article>
    """
  end

  @doc """
  Renders a customizable icon using a slot for SVG content.

  This component does not bind you to a specific set of icons. Instead, it
  provides a slot for inserting SVG content from any icon library you choose

  The `label` attribute is used to describe the icon and is by default applied
  as an `aria-label` for accessibility. If `label_placement` is set to
  `:left` or `:right`, the text becomes visible alongside the icon.

  ## Examples

  Render an icon with text as `aria-label` using the `heroicons` library:

      <.icon label="report bug"><Heroicons.bug_ant /></icon>

  To display the text visibly:

      <.icon label="report bug" label_placement={:right}>
        <Heroicons.bug_ant />
      </icon>

  > #### aria-hidden {: .info}
  >
  > Not all icon libraries set the `aria-hidden` attribute by default. Always
  > make sure that it is set on the `<svg>` element that the library renders.
  """
  @doc type: :component

  slot :inner_block, doc: "Slot for the SVG element."

  attr :label, :string,
    default: nil,
    doc: """
    Text that describes the icon. If `label_placement` is set to `:hidden`,
    this text is set as `aria-label` attribute.
    """

  attr :label_placement, :atom,
    default: :hidden,
    values: [:left, :right, :hidden],
    doc: """
    Position of the label relative to the icon. If set to `:hidden`, the
    `label` text is used as `aria-label` attribute.
    """

  attr :size, :atom, default: :medium, values: [:small, :medium, :large]

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def icon(assigns) do
    ~H"""
    <span
      class={
        [
          "icon",
          icon_size_class(@size),
          label_placement_class(@label_placement)
        ] ++ List.wrap(@class)
      }
      aria-label={if @label && @label_placement == :hidden, do: @label}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <span :if={@label && @label_placement != :hidden}><%= @label %></span>
    </span>
    """
  end

  defp label_placement_class(:hidden), do: nil
  defp label_placement_class(:left), do: "has-text-left"
  defp label_placement_class(:right), do: "has-text-right"

  defp icon_size_class(:small), do: "is-small"
  defp icon_size_class(:medium), do: "is-medium"
  defp icon_size_class(:large), do: "is-large"

  @doc """
  Renders an icon using an SVG sprite.

  ## Examples

  Render an icon with text as `aria-label`:

      <.icon name="arrow-left" label="Go back" />

  To display the text visibly:

      <.icon name="arrow-left" label="Go back" label_placement={:right} />
  """
  @doc type: :component

  attr :name, :string, required: true, doc: "Icon name as used in the sprite."

  attr :sprite_url, :string,
    default: "/assets/icons/sprite.svg",
    doc: "The URL of the SVG sprite."

  attr :label, :string,
    default: nil,
    doc: """
    Text that describes the icon. If `label_placement` is set to `:hidden`, this
    text is set as `aria-label` attribute.
    """

  attr :label_placement, :atom,
    default: :hidden,
    values: [:left, :right, :hidden],
    doc: """
    Position of the label relative to the icon. If set to `:hidden`, the
    `label` text is used as `aria-label` attribute.
    """

  attr :size, :atom, default: :medium, values: [:small, :medium, :large]

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def icon_sprite(assigns) do
    ~H"""
    <span
      class={
        [
          "icon",
          icon_size_class(@size),
          label_placement_class(@label_placement)
        ] ++ List.wrap(@class)
      }
      aria-label={if @label && @label_placement == :hidden, do: @label}
      {@rest}
    >
      <svg aria-hidden="true"><use href={"#{@sprite_url}##{@name}"} /></svg>
      <span :if={@label && @label_placement != :hidden}><%= @label %></span>
    </span>
    """
  end

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

      dialog.modal:not([open]),
      dialog.modal[open="false"] {
        display: none;
      }

  ## Semantics

  While the `showModal()` JavaScript function is typically recommended for
  managing modal dialog semantics, this component utilizes the `open` attribute
  to control visibility. This approach is chosen to eliminate the need for
  library consumers to add additional JavaScript code. To ensure proper
  modal semantics, the `aria-modal` attribute is added to the dialog element.
  """
  @doc type: :component

  attr :id, :string, required: true
  attr :open, :boolean, default: false, doc: "Initializes the modal as open."
  attr :on_cancel, JS, default: %JS{}

  slot :title, required: true
  slot :inner_block, required: true, doc: "The modal body."

  slot :close,
    doc: "The content for the 'close' link. Defaults to the word 'close'."

  slot :footer

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def modal(assigns) do
    ~H"""
    <dialog
      id={@id}
      class={["modal" | List.wrap(@class)]}
      aria-modal={(@open && "true") || "false"}
      aria-labelledby={"#{@id}-title"}
      open={@open}
      phx-mounted={@open && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      {@rest}
    >
      <.focus_wrap
        id={"#{@id}-container"}
        class="modal-container"
        phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
        phx-key="escape"
        phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
      >
        <article>
          <header>
            <.link
              href="#"
              class="modal-close"
              aria-label="Close"
              phx-click={JS.exec("data-cancel", to: "##{@id}")}
            >
              <%= render_slot(@close) %>
              <span :if={@close == []}>close</span>
            </.link>
            <h2 id={"#{@id}-title"}><%= render_slot(@title) %></h2>
          </header>
          <div id={"#{@id}-content"} class="modal-content">
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
  Renders a navigation bar.

  ## Usage

      <Doggo.navbar>
        <:brand><.link navigate={~p"/"}>Pet Clinic</.link></:brand>
        <Doggo.navbar_items>
          <:item><.link navigate={~p"/about"}>About</.link></:item>
          <:item><.link navigate={~p"/services"}>Services</.link></:item>
          <:item>
            <.link navigate={~p"/login"} class="button">Log in</.link>
          </:item>
        </Doggo.navbar_items>
      </Doggo.navbar>

  You can place multiple navigation item lists in the inner block. If the
  `.navbar` is styled as a flex box, you can use the CSS `order` property to
  control the display order of the brand and lists.

      <Doggo.navbar>
        <:brand><.link navigate={~p"/"}>Pet Clinic</.link></:brand>
        <Doggo.navbar_items class="navbar-main-links">
          <:item><.link navigate={~p"/about"}>About</.link></:item>
          <:item><.link navigate={~p"/services"}>Services</.link></:item>
        </Doggo.navbar_items>
        <Doggo.navbar_items class="navbar-user-menu">
          <:item>
            <.link navigate={~p"/login"} class="button">Log in</.link>
          </:item>
        </Doggo.navbar_items>
      </Doggo.navbar>

  If you have multiple `<nav>` elements on your page, it is recommended to set
  the `aria-label` attribute.

      <Doggo.navbar aria-label="main navigation">
        <!-- ... -->
      </Doggo.navbar>
  """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :brand, doc: "Slot for the brand name or logo."

  slot :inner_block,
    doc: """
    Slot for navbar items. Use the `navbar_items` component here to render
    navigation links or other controls.
    """

  def navbar(assigns) do
    ~H"""
    <nav class={["navbar" | List.wrap(@class)]} {@rest}>
      <div :if={@brand != []} class="navbar-brand">
        <%= render_slot(@brand) %>
      </div>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  @doc """
  Renders a list of navigation items.

  Meant to be used in the inner block of the `navbar` component.

  ## Usage

      <Doggo.navbar_items>
        <:item><.link navigate={~p"/about"}>About</.link></:item>
        <:item><.link navigate={~p"/services"}>Services</.link></:item>
        <:item>
          <.link navigate={~p"/login"} class="button">Log in</.link>
        </:item>
      </Doggo.navbar_items>
  """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :item,
    required: true,
    doc: "A navigation item, usually a link or a button."

  def navbar_items(assigns) do
    ~H"""
    <ul class={["navbar-items" | List.wrap(@class)]} {@rest}>
      <li :for={item <- @item}><%= render_slot(item) %></li>
    </ul>
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
  end

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def property_list(assigns) do
    ~H"""
    <dl class={["property-list" | List.wrap(@class)]} {@rest}>
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

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def stack(assigns) do
    ~H"""
    <div
      class={["stack", @recursive && "is-recursive"] ++ List.wrap(@class)}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
