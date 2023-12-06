defmodule Doggo do
  @moduledoc """
  Collection of Phoenix Components.
  """

  use Phoenix.Component

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS

  ## Components

  @doc """
  The action bar offers users quick access to primary actions within the
  application.

  It is typically positioned to float above other content.

  ## Example

      <.action_bar>
        <:item label="Edit" on_click={JS.push("edit")}>
          <.icon size={:small}><Lucideicons.pencil aria-hidden /></.icon>
        </:item>
        <:item label="Move" on_click={JS.push("move")}>
          <.icon size={:small}><Lucideicons.move aria-hidden /></.icon>
        </:item>
        <:item label="Archive" on_click={JS.push("archive")}>
          <.icon size={:small}><Lucideicons.archive aria-hidden /></.icon>
        </:item>
      </.action_bar>
  """
  @doc type: :component

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :item do
    attr :label, :string, required: true
    attr :on_click, JS, required: true
  end

  def action_bar(assigns) do
    ~H"""
    <div class={["action-bar" | List.wrap(@class)]} {@rest}>
      <.link :for={item <- @item} phx-click={item.on_click} title={item.label}>
        <%= render_slot(item) %>
      </.link>
    </div>
    """
  end

  @doc """
  The app bar is typically located at the top of the interface and provides
  access to key features and navigation options.

  ## Usage

      <.app_bar title="Page title">
        <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
          <.icon><Lucideicons.menu aria-hidden /></.icon>
        </:navigation>
        <:action label="Search" on_click={JS.push("search")}>
          <.icon><Lucideicons.search aria-hidden /></.icon>
        </:action>
        <:action label="Like" on_click={JS.push("like")}>
          <.icon><Lucideicons.heart aria-hidden /></.icon>
        </:action>
      </.app_bar>
  """
  @doc type: :component

  attr :title, :string,
    default: nil,
    doc: "The page title. Will be set as `h1`."

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :navigation,
    doc: """
    Slot for a single button left of the title, typically used for a menu button
    that toggles a drawer, or for a back link.
    """ do
    attr :label, :string, required: true
    attr :on_click, JS, required: true
  end

  slot :action, doc: "Slot for action buttons right of the title." do
    attr :label, :string, required: true
    attr :on_click, JS, required: true
  end

  def app_bar(assigns) do
    ~H"""
    <header class={["app-bar" | List.wrap(@class)]} {@rest}>
      <div :if={@navigation != []} class="app-bar-navigation">
        <.link
          :for={navigation <- @navigation}
          phx-click={navigation.on_click}
          title={navigation.label}
        >
          <%= render_slot(navigation) %>
        </.link>
      </div>
      <h1 :if={@title}><%= @title %></h1>
      <div :if={@action != []} class="app-bar-actions">
        <.link
          :for={action <- @action}
          phx-click={action.on_click}
          title={action.label}
        >
          <%= render_slot(action) %>
        </.link>
      </div>
    </header>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Confirm</.button>

      <.button type="submit" variant={:secondary} size={:medium} shape={:pill}>
        Submit
      </.button>
  """
  @doc type: :component

  attr :type, :string, values: ["button", "reset", "submit"], default: "button"

  attr :variant, :atom,
    values: [:primary, :secondary, :info, :success, :warning, :danger],
    default: :primary

  attr :fill, :atom, values: [:solid, :outline, :text], default: :solid

  attr :size, :atom,
    values: [:small, :normal, :medium, :large],
    default: :normal

  attr :shape, :atom, values: [nil, :circle, :pill], default: nil
  attr :disabled, :boolean, default: nil
  attr :rest, :global, include: ~w(autofocus form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        variant_class(@variant),
        size_class(@size),
        shape_class(@shape),
        fill_class(@fill)
      ]}
      disabled={@disabled}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a link (`<a>`) that has the role and style of a button.

  ## Examples

      <.button_link patch={~p"/confirm"}>Confirm</.button>

      <.button_link
        navigate={~p"/registration"}
        variant={:primary}
        shape={:pill}>
        Submit
      </.button>
  """
  @doc type: :component

  attr :variant, :atom,
    values: [:primary, :secondary, :info, :success, :warning, :danger],
    default: :primary

  attr :fill, :atom, values: [:solid, :outline, :text], default: :solid

  attr :size, :atom,
    values: [:small, :normal, :medium, :large],
    default: :normal

  attr :shape, :atom, values: [nil, :circle, :pill], default: nil

  attr :disabled, :boolean,
    default: false,
    doc: """
    Since `<a>` tags cannot have a `disabled` attribute, this attribute toggles
    the `"is-disabled"` class.
    """

  attr :rest, :global,
    include: [
      # HTML attributes
      "download",
      "hreflang",
      "referrerpolicy",
      "rel",
      "target",
      "type",
      # Phoenix.LiveView.Component.link/1 attributes
      "navigate",
      "patch",
      "href",
      "replace",
      "method",
      "csrf_token"
    ]

  slot :inner_block, required: true

  def button_link(assigns) do
    ~H"""
    <.link
      role="button"
      class={[
        variant_class(@variant),
        size_class(@size),
        shape_class(@shape),
        fill_class(@fill),
        @disabled && "is-disabled"
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @doc """
  Renders a `DateTime` or `NaiveDateTime` in a `<time>` tag.

  ## Examples

  By default, the given value is formatted for display with `to_string/1`. This:

      <.datetime value={~U[2023-02-05 12:22:06.003Z]} />

  Will be rendered as:

      <time datetime="2023-02-05T12:22:06.003Z">
        2023-02-05 12:22:06.003Z
      </time>

  You can also pass a custom formatter function. For example, if you are using
  [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
  application, you could do this:

      <.datetime
        value={~U[2023-02-05 14:22:06.003Z]}
        formatter={&MyApp.Cldr.DateTime.to_string!/1}
      />

  Which, depending on your locale, may be rendered as:

      <time datetime="2023-02-05T14:22:06.003Z">
        Feb 2, 2023, 14:22:06 PM
      </time>
  """
  @doc type: :component

  attr :value, :any,
    required: true,
    doc: """
    Either a `DateTime` or `NaiveDateTime`.
    """

  attr :formatter, :any,
    doc: """
    A function that takes a `DateTime` or a `NaiveDateTime` as an argument and
    returns the value formatted for display. Defaults to `to_string/1`.
    """

  attr :title_formatter, :any,
    default: nil,
    doc: """
    When provided, this function is used to format the date time value for the
    `title` attribute. If the attribute is not set, no `title` attribute will
    be added.
    """

  attr :precision, :atom,
    values: [:minute, :second, :millisecond, :microsecond, nil],
    default: nil,
    doc: """
    Precision to truncate the given value with. The truncation is applied on
    both the display value and the value of the `datetime` attribute.
    """

  attr :timezone, :string,
    default: nil,
    doc: """
    If set and the given value is a `DateTime`, the value will be shifted to
    that time zone. This affects both the display value and the `datetime` tag.
    Note that you need to
    [configure a time zone database](https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database)
    for this to work.
    """

  def datetime(
        %{value: value, precision: precision, timezone: timezone} = assigns
      ) do
    value =
      value
      |> shift_zone(timezone)
      |> truncate_datetime(precision)

    assigns =
      assigns
      |> assign(:value, value)
      |> assign_new(:formatter, fn -> &to_string/1 end)

    ~H"""
    <time
      :if={@value}
      datetime={datetime_attr(@value)}
      title={time_title_attr(@value, @title_formatter)}
    >
      <%= @formatter.(@value) %>
    </time>
    """
  end

  defp truncate_datetime(nil, _), do: nil
  defp truncate_datetime(v, nil), do: v
  defp truncate_datetime(v, :minute), do: %{v | second: 0, microsecond: {0, 0}}

  defp truncate_datetime(%DateTime{} = dt, precision) do
    DateTime.truncate(dt, precision)
  end

  defp truncate_datetime(%NaiveDateTime{} = dt, precision) do
    NaiveDateTime.truncate(dt, precision)
  end

  defp truncate_datetime(%Time{} = t, precision) do
    Time.truncate(t, precision)
  end

  defp shift_zone(%DateTime{} = dt, tz) when is_binary(tz) do
    DateTime.shift_zone!(dt, tz)
  end

  defp shift_zone(v, _), do: v

  defp datetime_attr(%DateTime{} = dt) do
    DateTime.to_iso8601(dt)
  end

  defp datetime_attr(%NaiveDateTime{} = dt) do
    NaiveDateTime.to_iso8601(dt)
  end

  defp time_title_attr(v, nil), do: v
  defp time_title_attr(v, fun) when is_function(fun, 1), do: fun.(v)

  @doc """
  Renders a `Date`, `DateTime`, or `NaiveDateTime` in a `<time>` tag.

  ## Examples

  By default, the given value is formatted for display with `to_string/1`. This:

      <.date value={~D[2023-02-05]} />

  Will be rendered as:

      <time datetime="2023-02-05">
        2023-02-05
      </time>

  You can also pass a custom formatter function. For example, if you are using
  [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
  application, you could do this:

      <.date
        value={~D[2023-02-05]}
        formatter={&MyApp.Cldr.Date.to_string!/1}
      />

  Which, depending on your locale, may be rendered as:

      <time datetime="2023-02-05">
        Feb 2, 2023
      </time>
  """
  @doc type: :component

  attr :value, :any,
    required: true,
    doc: """
    Either a `Date`, `DateTime`, or `NaiveDateTime`.
    """

  attr :formatter, :any,
    doc: """
    A function that takes a `Date` as an argument and returns the value
    formatted for display. Defaults to `to_string/1`.
    """

  attr :title_formatter, :any,
    default: nil,
    doc: """
    When provided, this function is used to format the date value for the
    `title` attribute. If the attribute is not set, no `title` attribute will
    be added.
    """

  attr :timezone, :string,
    default: nil,
    doc: """
    If set and the given value is a `DateTime`, the value will be shifted to
    that time zone. This affects both the display value and the `datetime` tag.
    Note that you need to
    [configure a time zone database](https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database)
    for this to work.
    """

  def date(%{value: value, timezone: timezone} = assigns) do
    value
    |> shift_zone(timezone)
    |> to_date()

    assigns =
      assigns
      |> assign(:value, value)
      |> assign_new(:formatter, fn -> &to_string/1 end)

    ~H"""
    <time
      :if={@value}
      datetime={Date.to_iso8601(@value)}
      title={time_title_attr(@value, @title_formatter)}
    >
      <%= @formatter.(@value) %>
    </time>
    """
  end

  defp to_date(%Date{} = d), do: d
  defp to_date(%DateTime{} = dt), do: DateTime.to_date(dt)
  defp to_date(%NaiveDateTime{} = dt), do: NaiveDateTime.to_date(dt)
  defp to_date(nil), do: nil

  @doc """
  Renders a `Time`, `DateTime`, or `NaiveDateTime` in a `<time>` tag.

  ## Examples

  By default, the given value is formatted for display with `to_string/1`. This:

      <.time value={~T[12:22:06.003Z]} />

  Will be rendered as:

      <time datetime="12:22:06.003">
        12:22:06.003
      </time>

  You can also pass a custom formatter function. For example, if you are using
  [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
  application, you could do this:

      <.time
        value={~T[12:22:06.003]}
        formatter={&MyApp.Cldr.Time.to_string!/1}
      />

  Which, depending on your locale, may be rendered as:

      <time datetime="14:22:06.003">
        14:22:06 PM
      </time>
  """
  @doc type: :component

  attr :value, :any,
    required: true,
    doc: """
    Either a `Time`, `DateTime`, or `NaiveDateTime`.
    """

  attr :formatter, :any,
    doc: """
    A function that takes a `Time`, `DateTime`, or `NaiveDateTime` as an
    argument and returns the value formatted for display. Defaults to
    `to_string/1`.
    """

  attr :title_formatter, :any,
    default: nil,
    doc: """
    When provided, this function is used to format the time value for the
    `title` attribute. If the attribute is not set, no `title` attribute will
    be added.
    """

  attr :precision, :atom,
    values: [:minute, :second, :millisecond, :microsecond, nil],
    default: nil,
    doc: """
    Precision to truncate the given value with. The truncation is applied on
    both the display value and the value of the `datetime` attribute.
    """

  attr :timezone, :string,
    default: nil,
    doc: """
    If set and the given value is a `DateTime`, the value will be shifted to
    that time zone. This affects both the display value and the `datetime` tag.
    Note that you need to
    [configure a time zone database](https://hexdocs.pm/elixir/DateTime.html#module-time-zone-database)
    for this to work.
    """

  def time(%{value: value, precision: precision, timezone: timezone} = assigns) do
    value =
      value
      |> shift_zone(timezone)
      |> truncate_datetime(precision)
      |> to_time()

    assigns =
      assigns
      |> assign(:value, value)
      |> assign_new(:formatter, fn -> &to_string/1 end)

    ~H"""
    <time
      :if={@value}
      datetime={Time.to_iso8601(@value)}
      title={time_title_attr(@value, @title_formatter)}
    >
      <%= @formatter.(@value) %>
    </time>
    """
  end

  defp to_time(%Time{} = t), do: t
  defp to_time(%DateTime{} = dt), do: DateTime.to_time(dt)
  defp to_time(%NaiveDateTime{} = dt), do: NaiveDateTime.to_time(dt)
  defp to_time(nil), do: nil

  @doc """
  Shows the flash messages as alerts.

  ## Hidden attribute

  This component uses the `hidden` attribute to hide alerts related to
  disconnections. If you explicitly set the CSS `display` property for the
  `alert/1` component, it may override the default browser behavior for the
  `hidden` attribute, in which case you will see these alerts flashing on each
  page load. To prevent this, add the following lines to your CSS styles:

  ```css
  [hidden] {
    display: none !important;
  }
  ```

  ## Examples

      <.flash_group flash={@flash} />
  """
  @doc type: :component

  attr :flash, :map, required: true, doc: "The map of flash messages."
  attr :info_title, :string, default: "Success"
  attr :error_title, :string, default: "Error"
  attr :id, :string, default: nil, doc: "An optional ID for the container."
  attr :class, :any, default: "stack", doc: "An optional class name."
  attr :rest, :global, doc: "Any additional HTML attributes."

  def flash_group(assigns) do
    ~H"""
    <div id={@id} class={@class} {@rest}>
      <.alert
        :if={msg = Phoenix.Flash.get(@flash, :info)}
        level={:info}
        title={@info_title}
        on_close={clear_flash(:info)}
      >
        <%= msg %>
      </.alert>
      <.alert
        :if={msg = Phoenix.Flash.get(@flash, :error)}
        level={:error}
        title={@error_title}
        on_close={clear_flash(:error)}
      >
        <%= msg %>
      </.alert>
      <.alert
        id="client-error"
        level={:error}
        title="Disconnected"
        phx-disconnected={JS.show(to: ".phx-client-error #client-error")}
        phx-connected={JS.hide(to: "#client-error")}
        hidden
      >
        Attempting to reconnect.
      </.alert>
      <.alert
        id="server-error"
        level={:error}
        title="Error"
        phx-disconnected={JS.show(to: ".phx-server-error #server-error")}
        phx-connected={JS.hide(to: "#server-error")}
        hidden
      >
        Please wait while we get back on track.
      </.alert>
    </div>
    """
  end

  defp clear_flash(level) do
    JS.push("lv:clear-flash", value: %{key: level})
  end

  @doc """
  The alert component serves as a notification mechanism to provide feedback to
  the user.
  """
  @doc type: :component

  attr :id, :string, default: nil

  attr :level, :atom,
    values: [:info, :success, :warning, :error],
    default: :info,
    doc: "Semantic level of the alert."

  attr :title, :string, default: nil, doc: "An optional title."

  attr :on_close, JS,
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

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block, required: true, doc: "The main content of the alert."
  slot :icon, doc: "Optional slot to render an icon."

  def alert(assigns) do
    ~H"""
    <div
      phx-click={@on_close}
      id={@id}
      role="alert"
      class={["alert", variant_class(@level)] ++ List.wrap(@class)}
      {@rest}
    >
      <div :if={@icon != []} class="alert-icon">
        <%= render_slot(@icon) %>
      </div>
      <div class="alert-body">
        <div :if={@title} class="alert-title"><%= @title %></div>
        <div class="alert-message"><%= render_slot(@inner_block) %></div>
      </div>
      <button :if={@on_close} phx-click={@on_close} class="alert-close">
        <%= @close_label %>
      </button>
    </div>
    """
  end

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
  @doc type: :component

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

  attr :size, :atom,
    default: :normal,
    values: [:small, :normal, :medium, :large]

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
          size_class(@size),
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
          size_class(@size),
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
  Renders a form field including input, label, errors, and description.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  In addition to all HTML input types, the following type values are also
  supported:

  - `"select"` - For `<select>` elements.

  ## Examples

      <.input field={@form[:name]} />

      <.input field={@form[:email]} type="email" />
  """
  @doc type: :component

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number
         password range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct, for example: @form[:name]"

  attr :errors, :list, default: []

  attr :validations, :list,
    doc: """
    A list of HTML input validation attributes (`required`, `minlength`,
    `maxlength`, `min`, `max`, `pattern`). The attributes are derived
    automatically from the form.
    """

  attr :checked_value, :string,
    default: "true",
    doc: "The value that is sent when the checkbox is checked."

  attr :checked, :boolean, doc: "The checked attribute for checkboxes."

  attr :prompt, :string,
    default: nil,
    doc: "An optional prompt for select elements."

  attr :options, :list,
    doc: """
    A list of options for a select element. See
    `Phoenix.HTML.Form.options_for_select/2`.
    """

  attr :multiple, :boolean,
    default: false,
    doc: """
    Sets the `multiple` attribute on a select element to allow selecting
    multiple options.
    """

  attr :rest, :global,
    include:
      ~w(accept autocomplete capture cols disabled form list max maxlength min
         minlength multiple passwordrules pattern placeholder readonly required
         rows size step)

  slot :description, doc: "A field description to render underneath the input."

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:validations, fn ->
      Form.input_validations(field.form, field.field)
    end)
    |> assign_new(:name, fn ->
      if assigns.multiple, do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <.label required={@validations[:required] || false} class="checkbox">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value={@checked_value}
          checked={@checked}
          aria-describedby={input_aria_describedby(@id, @errors, @description)}
          {@validations}
          {@rest}
        />
        <%= @label %>
      </.label>
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <.label for={@id} required={@validations[:required] || false}>
        <%= @label %>
      </.label>
      <div class={["select", @multiple && "is-multiple"]}>
        <select
          name={@name}
          id={@id}
          multiple={@multiple}
          aria-describedby={input_aria_describedby(@id, @errors, @description)}
          {@validations}
          {@rest}
        >
          <option :if={@prompt} value=""><%= @prompt %></option>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
      </div>
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <.label for={@id} required={@validations[:required] || false}>
        <%= @label %>
      </.label>
      <textarea
        name={@name}
        id={@id}
        aria-describedby={input_aria_describedby(@id, @errors, @description)}
        {@validations}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  def input(%{type: "hidden", value: values} = assigns) when is_list(values) do
    ~H"""
    <input :for={value <- @value} type="hidden" name={@name <> "[]"} value={value} />
    """
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" name={@name} value={@value} />
    """
  end

  def input(assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <.label for={@id} required={@validations[:required] || false}>
        <%= @label %>
      </.label>
      <input
        name={@name}
        id={@id}
        type={@type}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        aria-describedby={input_aria_describedby(@id, @errors, @description)}
        {@validations}
        {@rest}
      />
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  defp input_aria_describedby(_, [], []), do: nil
  defp input_aria_describedby(id, _, []), do: field_errors_id(id)
  defp input_aria_describedby(id, [], _), do: field_description_id(id)

  defp input_aria_describedby(id, _, _),
    do: "#{field_errors_id(id)} #{field_description_id(id)}"

  defp field_error_class([]), do: nil
  defp field_error_class(_), do: "has-errors"

  @doc """
  Renders the label for an input.
  """
  @doc type: :component

  attr :for, :string, default: nil, doc: "The ID of the input."

  attr :required, :boolean,
    default: false,
    doc: "If set to `true`, a 'required' mark is rendered."

  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} {@rest}>
      <%= render_slot(@inner_block) %>
      <.required_mark :if={@required} />
    </label>
    """
  end

  defp required_mark(assigns) do
    ~H"""
    <abbr class="label-required" aria-hidden="true" title="required">*</abbr>
    """
  end

  @doc """
  Renders the errors for an input.
  """
  @doc type: :component

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :errors, :list, required: true, doc: "A list of errors as strings."

  def field_errors(assigns) do
    ~H"""
    <ul :if={@errors != []} id={field_errors_id(@for)} class="field-errors">
      <li :for={error <- @errors}><%= error %></li>
    </ul>
    """
  end

  defp field_errors_id(id) when is_binary(id), do: "#{id}_errors"

  @doc """
  Renders the description of an input.
  """
  @doc type: :component

  attr :for, :string, required: true, doc: "The ID of the input."
  attr :description, :any

  def field_description(assigns) do
    ~H"""
    <div
      :if={@description != []}
      id={field_description_id(@for)}
      class="field-description"
    >
      <li><%= render_slot(@description) %></li>
    </div>
    """
  end

  defp field_description_id(id) when is_binary(id), do: "#{id}_description"

  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
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
    |> JS.push_focus()
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
  @doc type: :component

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
  @doc type: :component

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

  @doc """
  Renders a drawer with a `brand`, `top`, and `bottom` slot.

  Within the slots, you can use the `drawer_nav/1` and `drawer_section/1`
  components.

  ## Example

      <.drawer>
        <:brand>
          <.link navigate={~p"/"}>App</.link>
        </:brand>
        <:top>
          <.drawer_nav aria-label="Main navigation">
            <:item>
              <.link navigate={~p"/dashboard"}>Dashboard</.link>
            </:item>
            <:item>
              <.drawer_nested_nav>
                <:title>Content</:title>
                <:item current_page>
                  <.link navigate={~p"/posts"}>Posts</.link>
                </:item>
                <:item>
                  <.link navigate={~p"/comments"}>Comments</.link>
                </:item>
              </.drawer_nested_nav>
            </:item>
          </.drawer_nav>
          <.drawer_section>
            <:title>Search</:title>
            <:item><input type="search" placeholder="Search" /></:item>
          </.drawer_section>
        </:top>
        <:bottom>
          <.drawer_nav aria-label="User menu">
            <:item>
              <.link navigate={~p"/settings"}>Settings</.link>
            </:item>
            <:item>
              <.link navigate={~p"/logout"}>Logout</.link>
            </:item>
          </.drawer_nav>
        </:bottom>
      </.drawer>
  """
  @doc type: :component

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :brand, doc: "Optional slot for the brand name or logo."

  slot :top,
    doc: """
    Slot for content that is rendered after the brand, at the start of the
    side bar.
    """

  slot :bottom,
    doc: """
    Slot for content that is rendered at the end of the drawer, pinned to the
    bottom, if there is enough room.
    """

  def drawer(assigns) do
    ~H"""
    <aside class={["drawer" | List.wrap(@class)]} {@rest}>
      <div :if={@brand != []} class="drawer-brand">
        <%= render_slot(@brand) %>
      </div>
      <div :if={@top != []} class="drawer-top">
        <%= render_slot(@top) %>
      </div>
      <div :if={@bottom != []} class="drawer-bottom">
        <%= render_slot(@bottom) %>
      </div>
    </aside>
    """
  end

  @doc """
  Renders a navigation menu as a drawer section.

  This component must be placed within the `:top` or `:bottom` slot of the
  `drawer/1` component.

  To nest the navigation, use the `drawer_nested_nav/1` component within the
  `:item` slot.

  To render a drawer section that is not a navigation menu, use
  `drawer_section/1` instead.

  ## Example

      <.drawer_nav aria-label="Main navigation">
        <:item>
          <.link navigate={~p"/dashboard"}>Dashboard</.link>
        </:item>
        <:item>
          <.drawer_nested_nav>
            <:title>Content</:title>
            <:item current_page>
              <.link navigate={~p"/posts"}>Posts</.link>
            </:item>
            <:item>
              <.link navigate={~p"/comments"}>Comments</.link>
            </:item>
          </.drawer_nested_nav>
        </:item>
      </.drawer_nav>
  """
  @doc type: :component

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :title, doc: "An optional slot for the title of the menu."

  slot :item, required: true, doc: "Items" do
    attr :current_page, :boolean
  end

  def drawer_nav(assigns) do
    ~H"""
    <nav {@rest}>
      <div :if={@title != []} class="drawer-nav-title">
        <%= render_slot(@title) %>
      </div>
      <ul>
        <li
          :for={item <- @item}
          aria-current={Map.get(item, :current_page, false) && "page"}
        >
          <%= render_slot(item) %>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders nested navigation items within the `:item` slot of the `drawer_nav/1`
  component.

  ## Example

      <.drawer_nav aria-label="Main navigation">
        <:item>
          <.drawer_nested_nav>
            <:title>Content</:title>
            <:item current_page>
              <.link navigate={~p"/posts"}>Posts</.link>
            </:item>
            <:item>
              <.link navigate={~p"/comments"}>Comments</.link>
            </:item>
          </.drawer_nested_nav>
        </:item>
      </.drawer_nav>
  """
  @doc type: :component

  slot :title, doc: "An optional slot for the title of the nested menu section."

  slot :item, required: true, doc: "Items" do
    attr :current_page, :boolean
  end

  def drawer_nested_nav(assigns) do
    ~H"""
    <div :if={@title != []} class="drawer-nav-title">
      <%= render_slot(@title) %>
    </div>
    <ul>
      <li
        :for={item <- @item}
        aria-current={Map.get(item, :current_page, false) && "page"}
      >
        <%= render_slot(item) %>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a section in a drawer that contains one or more items, which are not
  navigation links.

  To render a drawer navigation, use `drawer_nav/1` instead.

  ## Example

      <.drawer_section>
        <:title>Search</:title>
        <:item><input type="search" placeholder="Search" /></:item>
      </.drawer_section>
  """
  @doc type: :component

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :title, doc: "An optional slot for the title of the section."

  slot :item, required: true, doc: "Items" do
    attr :class, :any,
      doc: "Additional CSS classes. Can be a string or a list of strings."
  end

  def drawer_section(assigns) do
    ~H"""
    <div class={["drawer-section" | List.wrap(@class)]} {@rest}>
      <div :if={@title != []} class="drawer-section-title">
        <%= render_slot(@title) %>
      </div>
      <div
        :for={item <- @item}
        class={["drawer-item" | item |> Map.get(:class, []) |> List.wrap()]}
      >
        <%= render_slot(item) %>
      </div>
    </div>
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

  ## Modifier classes

  defp fill_class(:solid), do: "is-solid"
  defp fill_class(:outline), do: "is-outline"
  defp fill_class(:text), do: "is-text"

  defp size_class(:small), do: "is-small"
  defp size_class(:normal), do: nil
  defp size_class(:medium), do: "is-medium"
  defp size_class(:large), do: "is-large"

  defp shape_class(:circle), do: "is-circle"
  defp shape_class(:pill), do: "is-pill"
  defp shape_class(nil), do: nil

  defp variant_class(:primary), do: "is-primary"
  defp variant_class(:secondary), do: "is-secondary"
  defp variant_class(:info), do: "is-info"
  defp variant_class(:success), do: "is-success"
  defp variant_class(:warning), do: "is-warning"
  defp variant_class(:danger), do: "is-danger"
  defp variant_class(:error), do: "is-danger"
  defp variant_class(_), do: nil
end
