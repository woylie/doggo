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
  Renders a badge, typically used for drawing attention to elements like
  notification counts.

  ## Examples

      <.badge>8</.badge>
  """

  attr :size, :atom,
    values: [:small, :normal, :medium, :large],
    default: :normal

  attr :variant, :atom,
    values: [nil, :primary, :secondary, :info, :success, :warning, :danger],
    default: nil

  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span class={["badge", size_class(@size), variant_class(@variant)]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @doc """
  Renders a box for a section on the page.

  ## Example

  Minimal example with only a box body:

    <.box>
      <p>This is a box.</p>
    </.box>

  With title, banner, action, and footer:

    <.box>
      <:title>Profile</:title>
      <:banner>
        <img src="banner-image.png" alt="" />
      </:banner>
      <:action>
        <.button_link patch={~p"/profiles/\#{@profile}/edit}>Edit</.button_link>
      </:action>

      <p>This is a profile.</p>

      <:footer>
        <p>Last edited: <%= @profile.updated_at %></p>
      </:footer>
    </.box>
  """
  @doc type: :component

  slot :title, doc: "The title for the box."

  slot :inner_block,
    required: true,
    doc: "Slot for the content of the box body."

  slot :action, doc: "A slot for action buttons related to the box."

  slot :banner,
    doc: "A slot that can be used to render a banner image in the header."

  slot :footer, doc: "An optional slot for the footer."

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def box(assigns) do
    ~H"""
    <section class={["box" | List.wrap(@class)]} {@rest}>
      <header :if={@title != [] || @banner != []}>
        <h2 :if={@title != []}><%= render_slot(@title) %></h2>
        <div :if={@action != []} class="box-actions">
          <%= for action <- @action do %>
            <%= render_slot(action) %>
          <% end %>
        </div>
        <div :if={@banner != []} class="box-banner">
          <%= render_slot(@banner) %>
        </div>
      </header>
      <%= render_slot(@inner_block) %>
      <footer :if={@footer != []}>
        <%= render_slot(@footer) %>
      </footer>
    </section>
    """
  end

  @doc """
  Renders a breadcrumb navigation.

  ## Example

      <.breadcrumb>
        <:item patch="/categories">Categories</:item>
        <:item patch="/categories/1">Reviews</:item>
        <:item patch="/categories/1/articles/1">The Movie</:item>
      </.breadcrumb>
  """
  @doc type: :component

  attr :aria_label, :string, default: "breadcrumb"

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :item, required: true do
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
  end

  def breadcrumb(%{item: items} = assigns) do
    [last_item | rest] = Enum.reverse(items)

    assigns =
      assign(assigns, :item, Enum.reverse([{:current, last_item} | rest]))

    ~H"""
    <nav aria-label="Breadcrumb" class={["breadcrumb" | List.wrap(@class)]} {@rest}>
      <ul>
        <li :for={item <- @item}>
          <.breadcrumb_link item={item} />
        </li>
      </ul>
    </nav>
    """
  end

  defp breadcrumb_link(%{item: {:current, current_item}} = assigns) do
    assigns = assign(assigns, :item, current_item)

    ~H"""
    <.link
      navigate={@item[:navigate]}
      patch={@item[:patch]}
      href={@item[:href]}
      aria-current="page"
    >
      <%= render_slot(@item) %>
    </.link>
    """
  end

  defp breadcrumb_link(assigns) do
    ~H"""
    <.link navigate={@item[:navigate]} patch={@item[:patch]} href={@item[:href]}>
      <%= render_slot(@item) %>
    </.link>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Confirm</.button>

      <.button type="submit" variant={:secondary} size={:medium} shape={:pill}>
        Submit
      </.button>

  To indicate a loading state, for example when submitting a form, use the
  `aria-busy` attribute:

      <.button aria-label="Saving..." aria-busy={true}>
        click me
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

  # don't add title attribute if no title formatter is set
  defp time_title_attr(_, nil), do: nil
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
    value =
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
  Renders a drawer with a `brand`, `top`, and `bottom` slot.

  Within the slots, you can use the `drawer_nav/1` and `drawer_section/1`
  components.

  ## Example

      <.drawer>
        <:brand>
          <.link navigate={~p"/"}>App</.link>
        </:brand>
        <:top>
          <.drawer_nav aria-label="Main">
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

      <.drawer_nav aria-label="Main">
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

      <.drawer_nav aria-label="Main">
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
  The fallback component renders a given value unless it is empty, in which case
  it renders a fallback value instead.

  The values `nil`, `""`, `[]` and `%{}` are treated as empty values.

  This component optionally applies a formatter function to non-empty values.

  The primary purpose of this component is to enhance accessibility. In
  situations where a value in a table column or property list is set to be
  invisible or not displayed, it's crucial to provide an alternative text for
  screen readers.

  ## Examples

  Render the value of `@some_value` if it's available, or display the
  default placeholder otherwise:

      <.fallback value={@some_value} />

  Apply a formatter function to `@some_value` if it is not `nil`:

      <.fallback value={@some_value} formatter={&format_date/1} />

  Set a custom placeholder and text for screen readers:

      <.fallback
        value={@some_value}
        placeholder="n/a"
        accessibility_text="not available"
      />
  """
  @doc type: :component

  attr :value, :any,
    required: true,
    doc: """
    The value to display. If the value is `nil`, `""`, `[]` or `%{}`, the
    placeholder is rendered instead.
    """

  attr :formatter, :any,
    default: nil,
    doc: """
    A 1-arity function that takes the value and returns the value for display.
    The formatter function is only applied if `value` is not an empty value.
    """

  attr :placeholder, :any,
    default: "-",
    doc: """
    The placeholder to render if the `value` is empty.
    """

  attr :accessibility_text, :string,
    default: "not set",
    doc: """
    The text for the `aria-label` attribute in case the `value` is empty.
    """

  def fallback(%{value: value} = assigns) when value in [nil, "", [], %{}] do
    ~H"""
    <span aria-label={@accessibility_text}><%= @placeholder %></span>
    """
  end

  def fallback(%{formatter: formatter} = assigns)
      when is_function(formatter, 1) do
    ~H"<%= @formatter.(@value) %>"
  end

  def fallback(%{formatter: nil} = assigns) do
    ~H"<%= @value %>"
  end

  @doc """
  Renders a frame with an aspect ratio for images or videos.

  This component is used within the `image/1` component.

  ## Example

  Rendering an image with the aspect ratio 4:3.

      <.frame ratio={{4, 3}}>
        <img src="image.png" alt="An example image illustrating the usage." />
      </.frame>

  Rendering an image as a circle.

      <.frame circle>
        <img src="image.png" alt="An example image illustrating the usage." />
      </.frame>
  """
  @doc type: :component

  attr :ratio, :any,
    values: [
      nil,
      {1, 1},
      {3, 2},
      {2, 3},
      {4, 3},
      {3, 4},
      {5, 4},
      {4, 5},
      {16, 9},
      {9, 16}
    ],
    default: nil

  attr :circle, :boolean, default: false

  slot :inner_block

  def frame(assigns) do
    ~H"""
    <div class={["frame", ratio_class(@ratio), @circle && shape_class(:circle)]}>
      <%= render_slot(@inner_block) %>
    </div>
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
  Renders an image with an optional caption.

  ## Example

      <.image
        src="https://github.com/woylie/doggo/blob/main/dog_poncho.jpg?raw=true"
        alt="A dog wearing a colorful poncho walks down a fashion show runway."
        ratio={{16, 9}}
      >
        <:caption>
          Spotlight on canine couture: A dog fashion show where four-legged models
          dazzle the runway with the latest in pet apparel.
        </:caption>
      </.image>
  """
  @doc type: :component

  attr :src, :string, required: true, doc: "The URL of the image to render."

  attr :srcset, :any,
    default: nil,
    doc: """
    A set of image URLs in different sizes. Can be passed as a string or a map.

    For example, this map:

        %{
          "1x" => "images/image-1x.jpg",
          "2x" => "images/image-2x.jpg"
        }

    Will result in this `srcset`:

        "images/image-1x.jpg 1x, images/image-2x.jpg 2x"

    See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/srcset.
    """

  attr :sizes, :string,
    default: nil,
    doc: """
    Specifies media conditions for the image widths, if the `srcset` attribute
    uses intrinsic widths.

    See https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/sizes.
    """

  attr :alt, :string,
    required: true,
    doc: """
    A text description of the image for screen reader users and those with slow
    internet. Effective alt text should concisely capture the image's essence
    and function, considering its context within the content. Aim for clarity
    and inclusivity without repeating information already conveyed by
    surrounding text, and avoid starting with "Image of" as screen readers
    automatically announce image presence.
    """

  attr :width, :integer, default: nil
  attr :height, :integer, default: nil
  attr :loading, :string, values: ["eager", "lazy"], default: "lazy"

  attr :ratio, :any,
    values: [
      nil,
      {1, 1},
      {3, 2},
      {2, 3},
      {4, 3},
      {3, 4},
      {5, 4},
      {4, 5},
      {16, 9},
      {9, 16}
    ],
    default: nil

  attr :rest, :global, doc: "Any additional HTML attributes."
  slot :caption

  def image(assigns) do
    ~H"""
    <figure {@rest}>
      <.frame ratio={@ratio}>
        <img
          src={@src}
          width={@width}
          height={@height}
          alt={@alt}
          loading={@loading}
          srcset={build_srcset(@srcset)}
          sizes={@sizes}
        />
      </.frame>
      <figcaption :if={@caption != []}><%= render_slot(@caption) %></figcaption>
    </figure>
    """
  end

  defp build_srcset(nil), do: nil
  defp build_srcset(srcset) when is_binary(srcset), do: srcset

  defp build_srcset(%{} = srcset) do
    Enum.map_join(srcset, ", ", fn {width_or_density, url} ->
      "#{url} #{width_or_density}"
    end)
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

  ## Gettext

  To translate field errors using Gettext, configure your Gettext module in
  `config/config.exs`.

      config :doggo, gettext: MyApp.Gettext

  Alternatively, pass the Gettext module as an attribute:

      <.input field={@form[:name]} gettext={MyApp.Gettext} />

  ## Label positioning

  The component does not provide an attribute to modify label positioning
  directly. Instead, label positioning should be handled with CSS. If your
  application requires different label positions, such as horizontal and
  vertical layouts, it is recommended to add a modifier class to the form.

  For example, the default style could position labels above inputs. To place
  labels to the left of the inputs in a horizontal form layout, you can add an
  `is-horizontal` class to the form:

      <.form class="is-horizontal">
        <!-- inputs -->
      </.form>

  Then, in your CSS, apply the necessary styles to the `.field` class within
  forms having the `is-horizontal` class:

      form.is-horizontal .field {
        // styles to position label left of the input
      }

  The component has a `hide_label` attribute to visually hide labels while still
  making them accessible to screen readers. If all labels within a form need to
  be visually hidden, it may be more convenient to define a
  `.has-visually-hidden-labels` modifier class for the `<form>`.

      <.form class="has-visually-hidden-labels">
        <!-- inputs -->
      </.form>

  Ensure to take checkbox and radio labels into consideration when writing the
  CSS styles.

  ## Examples

      <.input field={@form[:name]} />

      <.input field={@form[:email]} type="email" />

  ### Radio group and checkbox group

  The `radio-group` and `checkbox-group` types allow you to easily render groups
  of radio buttons or checkboxes with a single component invocation. The
  `options` attribute is required for these types and has the same format as
  the options for the `select` type, except that options may not be nested.

      <.input
        field={@form[:email]}
        type="checkbox-group"
        label="Cuisine"
        options={[
          {"Mexican", "mexican"},
          {"Japanese", "japanese"},
          {"Libanese", "libanese"}
        ]}
      />

  Note that the `checkbox-group` type renders an additional hidden input with
  an empty value before the checkboxes. This ensures that a value exists in case
  all checkboxes are unchecked. Consequently, the resulting list value includes
  an extra empty string. While `Ecto.Changeset.cast/3` filters out empty strings
  in array fields by default, you may need to handle the additional empty string
  manual in other contexts.
  """
  @doc type: :component

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil

  attr :hide_label, :boolean,
    default: false,
    doc: """
    Adds an "is-visually-hidden" class to the `<label>`. This option does not
    apply to checkbox and radio inputs.
    """

  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox checkbox-group color date datetime-local email file
         hidden month number password range radio radio-group search select
         switch tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "A form field struct, for example: @form[:name]"

  attr :errors, :list

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
    A list of options for a select element or a radio group. See
    `Phoenix.HTML.Form.options_for_select/2`. Note that the checkbox group and
    radio group do not support nesting.
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

  attr :gettext, :atom,
    doc: """
    The Gettext module to use for translating error messages. This option can
    also be set globally, see above.
    """

  slot :description, doc: "A field description to render underneath the input."

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    gettext_module =
      Map.get(assigns, :gettext, Application.get_env(:doggo, :gettext))

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(
      :errors,
      fn -> Enum.map(field.errors, &translate_error(&1, gettext_module)) end
    )
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

  def input(%{type: "checkbox-group"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <fieldset class="checkbox-group">
        <legend>
          <%= @label %>
          <.required_mark required={@validations[:required] || false} />
        </legend>
        <div>
          <input type="hidden" name={@name <> "[]"} value="" />
          <.checkbox
            :for={option <- @options}
            option={option}
            name={@name}
            id={@id}
            value={@value}
            errors={@errors}
            description={@description}
          />
        </div>
      </fieldset>
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  def input(%{type: "radio-group"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <fieldset class="radio-group">
        <legend>
          <%= @label %>
          <.required_mark required={@validations[:required] || false} />
        </legend>
        <div>
          <.radio
            :for={option <- @options}
            option={option}
            name={@name}
            id={@id}
            value={@value}
            errors={@errors}
            description={@description}
          />
        </div>
      </fieldset>
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  def input(%{type: "switch"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <.label required={@validations[:required] || false} class="switch">
        <span class="switch-label"><%= @label %></span>
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          role="switch"
          name={@name}
          id={@id}
          value={@checked_value}
          checked={@checked}
          aria-describedby={input_aria_describedby(@id, @errors, @description)}
          {@validations}
          {@rest}
        />
        <span class="switch-state">
          <span
            class={if @checked, do: "switch-state-on", else: "switch-state-off"}
            aria-hidden="true"
          >
            <%= if @checked do %>
              On
            <% else %>
              Off
            <% end %>
          </span>
        </span>
      </.label>
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]} phx-feedback-for={@name}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        visually_hidden={@hide_label}
      >
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
      <.label
        for={@id}
        required={@validations[:required] || false}
        visually_hidden={@hide_label}
      >
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
      <.label
        for={@id}
        required={@validations[:required] || false}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <input
        name={@name}
        id={@id}
        type={@type}
        value={normalize_value(@type, @value)}
        aria-describedby={input_aria_describedby(@id, @errors, @description)}
        {@validations}
        {@rest}
      />
      <.field_errors for={@id} errors={@errors} />
      <.field_description for={@id} description={@description} />
    </div>
    """
  end

  defp normalize_value("date", %struct{} = value)
       when struct in [Date, NaiveDateTime, DateTime] do
    <<date::10-binary, _::binary>> = struct.to_string(value)
    {:safe, date}
  end

  defp normalize_value("date", <<date::10-binary, _::binary>>) do
    {:safe, date}
  end

  defp normalize_value("date", _), do: ""
  defp normalize_value(type, value), do: Form.normalize_value(type, value)

  defp input_aria_describedby(_, [], []), do: nil
  defp input_aria_describedby(id, _, []), do: field_errors_id(id)
  defp input_aria_describedby(id, [], _), do: field_description_id(id)

  defp input_aria_describedby(id, _, _),
    do: "#{field_errors_id(id)} #{field_description_id(id)}"

  defp field_error_class([]), do: nil
  defp field_error_class(_), do: "has-errors"

  defp checkbox(%{option_value: _} = assigns) do
    ~H"""
    <.label class="checkbox">
      <input
        type="checkbox"
        name={@name <> "[]"}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={checked?(@option_value, @value)}
        aria-describedby={input_aria_describedby(@id, @errors, @description)}
      />
      <%= @label %>
    </.label>
    """
  end

  defp checkbox(%{option: {option_label, option_value}} = assigns) do
    assigns
    |> assign(label: option_label, option_value: option_value, option: nil)
    |> checkbox()
  end

  defp checkbox(%{option: option_value} = assigns) do
    assigns
    |> assign(
      label: humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> checkbox()
  end

  defp radio(%{option_value: _} = assigns) do
    ~H"""
    <.label>
      <input
        type="radio"
        name={@name}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={checked?(@option_value, @value)}
        aria-describedby={input_aria_describedby(@id, @errors, @description)}
      />
      <%= @label %>
    </.label>
    """
  end

  defp radio(%{option: {option_label, option_value}} = assigns) do
    assigns
    |> assign(label: option_label, option_value: option_value, option: nil)
    |> radio()
  end

  defp radio(%{option: option_value} = assigns) do
    assigns
    |> assign(
      label: humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> radio()
  end

  defp checked?(option, value) when is_list(value) do
    Phoenix.HTML.html_escape(option) in Enum.map(
      value,
      &Phoenix.HTML.html_escape/1
    )
  end

  defp checked?(option, value) do
    Phoenix.HTML.html_escape(option) == Phoenix.HTML.html_escape(value)
  end

  @doc """
  Renders the label for an input.
  """
  @doc type: :component

  attr :for, :string, default: nil, doc: "The ID of the input."

  attr :required, :boolean,
    default: false,
    doc: "If set to `true`, a 'required' mark is rendered."

  attr :visually_hidden, :boolean,
    default: false,
    doc: """
    Adds an "is-visually-hidden" class to the `<label>`.
    """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={[@visually_hidden && "is-visually-hidden" | List.wrap(@class)]}
      {@rest}
    >
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
      <%= render_slot(@description) %>
    </div>
    """
  end

  defp field_description_id(id) when is_binary(id), do: "#{id}_description"

  defp translate_error({msg, opts}, nil) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  defp translate_error({msg, opts}, gettext_module)
       when is_atom(gettext_module) do
    if count = opts[:count] do
      Gettext.dngettext(gettext_module, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(gettext_module, "errors", msg, opts)
    end
  end

  @doc """
  Use the field group component to visually group multiple inputs in a form.

  This component is intended for styling purposes and does not provide semantic
  grouping. For semantic grouping of related form elements, use the `<fieldset>`
  and `<legend>` HTML elements instead.

  ## Examples

  Visual grouping of inputs:

      <.field_group>
        <.input field={@form[:given_name]} label="Given name" />
        <.input field={@form[:family_name]} label="Family name"/>
      </.field_group>

  Semantic grouping (for reference):

      <fieldset>
        <legend>Personal Information</legend>
        <.input field={@form[:given_name]} label="Given name" />
        <.input field={@form[:family_name]} label="Family name"/>
      </fieldset>
  """
  @doc type: :component

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block, required: true

  def field_group(assigns) do
    ~H"""
    <div class={["field-group" | List.wrap(@class)]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
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
            <.button_link navigate={~p"/login"}>Log in</button_link>
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
  Renders a header that is specific to the content of the current page.

  Unlike a site-wide header, which offers consistent navigation and elements
  like logos throughout the website or application, this component is meant
  to describe the unique content of each page. For instance, on an article page,
  it would display the article's title.

  It is typically used as a direct child of the `<main>` element.

  ## Example

      <main>
        <.page_header title="Puppy Profiles" subtitle="Share Your Pup's Story">
          <:action>
            <.button_link patch={~p"/puppies/new"}>Add New Profile</.button_link>
          </:action>
        </.page_header>

        <section>
          <!-- Content -->
        </section>
      </main>
  """
  @doc type: :component

  attr :title, :string, required: true, doc: "The title for the current page."
  attr :subtitle, :string, default: nil, doc: "An optional sub title."

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :action, doc: "A slot for action buttons related to the current page."

  def page_header(assigns) do
    ~H"""
    <header class={["page-header" | List.wrap(@class)]} {@rest}>
      <div class="page-header-title">
        <h1><%= @title %></h1>
        <h2 :if={@subtitle}><%= @subtitle %></h2>
      </div>
      <div :if={@action != []} class="page-header-actions">
        <%= for action <- @action do %>
          <%= render_slot(action) %>
        <% end %>
      </div>
    </header>
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
  Renders a skeleton loader, a placeholder for content that is in the process of
  loading.

  It mimics the layout of the actual content, providing a better user experience
  during loading phases.

  ## Usage

  Render one of several primitive types:

      <.skeleton type={:text_line} />

  Combine primitives for complex layouts:

      <div class="card-skeleton" aria-busy="true">
        <.skeleton type={:image} />
        <.skeleton type={:text_line} />
        <.skeleton type={:text_line} />
        <.skeleton type={:text_line} />
        <.skeleton type={:rectangle} />
      </div>

  To modify the primitives for your use cases, you can use custom classes or CSS
  properties:

      <.skeleton type={:text_line} class="header" />

      <.skeleton type={:image} style="--aspect-ratio: 75%;" />

  ## Aria-busy attribute

  When using skeleton loaders, apply `aria-busy="true"` to the container element
  that contains the skeleton layout. For standalone use, add the attribute
  directly to the individual skeleton loader.

  ## Async result component

  The easiest way to load data asynchronously and render a skeleton loader is
  to use LiveView's
  [async operations](`m:Phoenix.LiveView#module-async-operations`)
  and `Phoenix.Component.async_result/1`.

  Assuming you defined a card skeleton component as described above:

      <.async_result :let={puppy} assign={@puppy}>
        <:loading><.card_skeleton /></:loading>
        <:failed :let={_reason}>There was an error loading the puppy.</:failed>
        <!-- Card for loaded content -->
      </.async_result>
  """
  @doc type: :component

  attr :type, :atom,
    required: true,
    values: [
      :text_line,
      :text_block,
      :image,
      :circle,
      :rectangle,
      :square
    ]

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def skeleton(assigns) do
    ~H"""
    <div
      class={["skeleton", skeleton_type_class(@type)] ++ List.wrap(@class)}
      {@rest}
    >
    </div>
    """
  end

  @doc """
  Renders a switch as a button.

  If you want to render a switch as part of a form, use the `input/1` component
  with the type `"switch"` instead.

  Note that this component only renders a button with a label, a state, and
  `<span>` with the class `switch-control`. You will need to style the switch
  control span with CSS in order to give it the appearance of a switch.

  ## Examples

      <.switch
        label="Subscribe"
        checked={true}
        phx-click="toggle-subscription"
      />
  """
  @doc type: :component

  attr :label, :string, required: true
  attr :on_text, :string, default: "On"
  attr :off_text, :string, default: "Off"
  attr :checked, :boolean, required: true
  attr :rest, :global

  def switch(assigns) do
    ~H"""
    <button type="button" role="switch" aria-checked={to_string(@checked)} {@rest}>
      <span class="switch-label"><%= @label %></span>
      <span class="switch-control"><span></span></span>
      <span class="switch-state">
        <span
          class={if @checked, do: "switch-state-on", else: "switch-state-off"}
          aria-hidden="true"
        >
          <%= if @checked do %>
            <%= @on_text %>
          <% else %>
            <%= @off_text %>
          <% end %>
        </span>
      </span>
    </button>
    """
  end

  @doc """
  Renders a simple table.

  ## Examples

      <.table id="pets" rows={@pets}>
        <:col :let={p} label="name"><%= p.name %></:col>
        <:col :let={p} label="age"><%= p.age %></:col>
      </.table>
  """
  @doc type: :component

  attr :id, :string, required: true

  attr :rows, :list,
    required: true,
    doc: "The list of items to be displayed in rows."

  attr :caption, :string,
    default: nil,
    doc: "Content for the `<caption>` element."

  attr :row_id, :any,
    default: nil,
    doc: """
    Overrides the default function that retrieves the row ID from a stream item.
    """

  attr :row_click, JS,
    default: nil,
    doc: """
    Sets the `phx-click` function attribute for each row `td`. Expects to be a
    function that receives a row item as an argument. This does not add the
    `phx-click` attribute to the `action` slot.

    Example:

    ```elixir
    row_click={&JS.navigate(~p"/users/\#{&1}")}
    ```
    """

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: """
    This function is called on the row item before it is passed to the :col
    and :action slots.
    """

  slot :col,
    required: true,
    doc: """
    For each column to render, add one `<:col>` element.

    ```elixir
    <:col :let={pet} label="Name" field={:name} col_style="width: 20%;">
      <%= pet.name %>
    </:col>
    ```

    Any additional assigns will be added as attributes to the `<td>` elements.

    """ do
    attr :label, :any, doc: "The content for the header column."

    attr :col_attrs, :string,
      doc: """
      If set, a `<colgroup>` element is rendered and the attributes are added
      to the `<col>` element of the respective column.
      """
  end

  slot :action,
    doc: """
    The slot for showing user actions in the last table column. These columns
    do not receive the `row_click` attribute.


    ```elixir
    <:action :let={user}>
      <.link navigate={~p"/users/\#{user}"}>Show</.link>
    </:action>
    ```
    """ do
    attr :label, :string, doc: "The content for the header column."

    attr :col_attrs, :string,
      doc: """
      If set, a `<colgroup>` element is rendered and the attributes are added
      to the `<col>` element of the respective column.
      """
  end

  slot :foot,
    default: nil,
    doc: """
    You can optionally add a `foot`. The inner block will be rendered inside
    a `tfoot` element.

        <Flop.Phoenix.table>
          <:foot>
            <tr><td>Total: <span class="total"><%= @total %></span></td></tr>
          </:foot>
        </Flop.Phoenix.table>
    """

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="table-container">
      <table id={@id}>
        <caption :if={@caption}><%= @caption %></caption>
        <colgroup :if={
          Enum.any?(@col, & &1[:col_attrs]) or Enum.any?(@action, & &1[:col_attrs])
        }>
          <col :for={col <- @col} {col[:col_attrs] || []} />
          <col :for={action <- @action} {action[:col_attrs] || []} />
        </colgroup>
        <thead>
          <tr>
            <th :for={col <- @col}><%= col[:label] %></th>
            <th :for={action <- @action}><%= action[:label] %></th>
          </tr>
        </thead>
        <tbody
          id={@id <> "-tbody"}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
            <td :for={col <- @col} phx-click={@row_click && @row_click.(row)}>
              <%= render_slot(col, @row_item.(row)) %>
            </td>
            <td :for={action <- @action}>
              <%= render_slot(action, @row_item.(row)) %>
            </td>
          </tr>
        </tbody>
        <tfoot :if={@foot != []}><%= render_slot(@foot) %></tfoot>
      </table>
    </div>
    """
  end

  @doc """
  Renders navigation tabs.

  ## Example

      <.tab_navigation current_value={@live_action}>
        <:item
          patch={~p"/pets/\#{@pet}"}
          value={[:show, :edit]}
        >
          Profile
        </:item>
        <:item
          patch={~p"/pets/\#{@pet}/appointments"}
          value={:appointments}
        >
          Appointments
        </:item>
        <:item
          patch={~p"/pets/\#{@pet}/messages"}
          value={:messages}
        >
          Messages
        </:item>
      </.tab_navigation>
  """
  @doc type: :component

  attr :label, :string,
    default: "Tabs",
    doc: """
    Label for the `<nav>` element. The label is especially important if you have
    multiple `<nav>` elements on the same page. If the page is localized, the
    label should be translated, too. Do not include "navigation" in the label,
    since screen readers will already announce the "navigation" role as part
    of the label.
    """

  attr :current_value, :any,
    required: true,
    doc: """
    The current value used to compare the item values with. If you use this
    component to patch between different view actions, this could be the
    `@live_action` attribute.
    """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :item, required: true do
    attr :href, :string, doc: "Passed to `Phoenix.Component.link/1`."
    attr :navigate, :string, doc: "Passed to `Phoenix.Component.link/1`."
    attr :patch, :string, doc: "Passed to `Phoenix.Component.link/1`."

    attr :value, :any,
      doc: """
      The value of the item is compared to the `current_value` attribute to
      determine whether to add the `aria-current` attribute. This can be a
      single value or a list of values, e.g. multiple live actions for which
      the item should be marked as current.
      """
  end

  def tab_navigation(assigns) do
    ~H"""
    <nav aria-label={@label} class={["tab-navigation" | List.wrap(@class)]} {@rest}>
      <ul>
        <li :for={item <- @item}>
          <.link
            href={item[:href]}
            navigate={item[:navigate]}
            patch={item[:patch]}
            aria-current={@current_value in List.wrap(item.value) && "page"}
          >
            <%= render_slot(item) %>
          </.link>
        </li>
      </ul>
    </nav>
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

  @doc """
  Renders a tag, typically used for displaying labels, categories, or keywords.

  ## Examples

  Plain tag:

      <.tag>Well-Trained</.tag>

  With icon:

      <.tag>
        Puppy
        <.icon><Heroicons.edit /></icon>
      </.tag>

  With delete button:

      <.tag>
        High Energy
        <button
          phx-click="remove-tag"
          phx-value-tag="high-energy"
          aria-label="Remove tag"
        >
          <.icon><Heroicons.x /></icon>
        </button>
      </.tag>
  """

  attr :size, :atom,
    values: [:small, :normal, :medium, :large],
    default: :normal

  attr :variant, :atom,
    values: [nil, :primary, :secondary, :info, :success, :warning, :danger],
    default: nil

  attr :shape, :atom, values: [nil, :pill], default: nil

  slot :inner_block, required: true

  def tag(assigns) do
    ~H"""
    <span class={[
      "tag",
      size_class(@size),
      variant_class(@variant),
      shape_class(@shape)
    ]}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  ## Helpers

  defp humanize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> humanize()
  end

  defp humanize(s) when is_binary(s) do
    if String.ends_with?(s, "_id") do
      s |> binary_part(0, byte_size(s) - 3) |> to_titlecase()
    else
      to_titlecase(s)
    end
  end

  defp to_titlecase(s) do
    s
    |> String.replace("_", " ")
    |> :string.titlecase()
  end

  ## Modifier classes

  defp fill_class(:solid), do: "is-solid"
  defp fill_class(:outline), do: "is-outline"
  defp fill_class(:text), do: "is-text"

  defp ratio_class({1, 1}), do: "is-1-to-1"
  defp ratio_class({3, 2}), do: "is-3-to-2"
  defp ratio_class({2, 3}), do: "is-2-to-3"
  defp ratio_class({4, 3}), do: "is-4-to-3"
  defp ratio_class({3, 4}), do: "is-3-to-4"
  defp ratio_class({5, 4}), do: "is-5-to-4"
  defp ratio_class({4, 5}), do: "is-4-to-5"
  defp ratio_class({16, 9}), do: "is-16-to-9"
  defp ratio_class({9, 16}), do: "is-9-to-16"
  defp ratio_class(nil), do: nil

  defp size_class(:small), do: "is-small"
  defp size_class(:normal), do: nil
  defp size_class(:medium), do: "is-medium"
  defp size_class(:large), do: "is-large"

  defp shape_class(:circle), do: "is-circle"
  defp shape_class(:pill), do: "is-pill"
  defp shape_class(nil), do: nil

  defp skeleton_type_class(:text_line), do: "is-text-line"
  defp skeleton_type_class(:text_block), do: "is-text-block"
  defp skeleton_type_class(:image), do: "is-image"
  defp skeleton_type_class(:circle), do: "is-circle"
  defp skeleton_type_class(:rectangle), do: "is-rectangle"
  defp skeleton_type_class(:square), do: "is-square"

  defp variant_class(:primary), do: "is-primary"
  defp variant_class(:secondary), do: "is-secondary"
  defp variant_class(:info), do: "is-info"
  defp variant_class(:success), do: "is-success"
  defp variant_class(:warning), do: "is-warning"
  defp variant_class(:danger), do: "is-danger"
  defp variant_class(:error), do: "is-danger"
  defp variant_class(_), do: nil
end
