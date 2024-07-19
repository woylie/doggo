defmodule Doggo do
  @moduledoc """
  Collection of Phoenix Components.
  """

  use Phoenix.Component

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS

  @fills [:solid, :outline, :text]
  @ratios [
    {1, 1},
    {3, 2},
    {2, 3},
    {4, 3},
    {3, 4},
    {5, 4},
    {4, 5},
    {16, 9},
    {9, 16}
  ]
  @shapes [:circle, :pill]
  @sizes [:small, :normal, :medium, :large]
  @skeleton_types [
    :text_line,
    :text_block,
    :image,
    :circle,
    :rectangle,
    :square
  ]
  @variants [:primary, :secondary, :info, :success, :warning, :danger]

  ## Components

  @doc """
  Renders an alert dialog that requires the immediate attention and response of
  the user.

  This component is meant for situations where critical information must be
  conveyed, and an explicit response is required from the user. It is typically
  used for confirmation dialogs, warning messages, error notifications, and
  other scenarios where an immediate decision is necessary.

  For non-critical dialogs, such as those containing forms or additional
  information, use `Doggo.Components.modal/1` instead.

  ## Usage

  ```heex
  <Doggo.alert_dialog id="end-session-modal">
    <:title>End Training Session Early?</:title>
    <p>
      Are you sure you want to end the current training session with Bella?
      She's making great progress today!
    </p>
    <:footer>
      <Doggo.button phx-click="end-session">
        Yes, end session
      </Doggo.button>
      <Doggo.button phx-click={JS.exec("data-cancel", to: "#end-session-modal")}>
        No, continue training
      </Doggo.button>
    </:footer>
  </Doggo.alert_dialog>
  ```

  To open the dialog, use the `show_modal/1` function.

  ```heex
  <Doggo.button
    phx-click={Doggo.show_modal("end-session-modal")}
    aria-haspopup="dialog"
  >
    show
  </Doggo.button>
  ```

  ## CSS

  To hide the modal when the `open` attribute is not set, use the following CSS
  styles:

  ```css
  dialog.alert-dialog:not([open]),
  dialog.alert-dialog[open="false"] {
    display: none;
  }
  ```

  ## Semantics

  While the `showModal()` JavaScript function is typically recommended for
  managing modal dialog semantics, this component utilizes the `open` attribute
  to control visibility. This approach is chosen to eliminate the need for
  library consumers to add additional JavaScript code. To ensure proper
  modal semantics, the `aria-modal` attribute is added to the dialog element.
  """
  @doc type: :component
  @doc since: "0.5.0"

  attr :id, :string, required: true
  attr :open, :boolean, default: false, doc: "Initializes the dialog as open."

  attr :on_cancel, JS,
    default: %JS{},
    doc: """
    An additional `Phoenix.LiveView.JS` command to execute when the dialog
    is canceled. This command is executed in addition to closing the dialog. If
    you only want the dialog to be closed, you don't have to set this attribute.
    """

  attr :dismissable, :boolean,
    default: false,
    doc: """
    When set to `true`, the dialog can be dismissed by clicking a close button
    or by pressing the escape key.
    """

  attr :close_label, :string,
    default: "Close",
    doc: "Aria label for the close button."

  slot :title, required: true
  slot :inner_block, required: true, doc: "The modal body."

  slot :close,
    doc: "The content for the 'close' link. Defaults to the word 'close'."

  slot :footer

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def alert_dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      role="alertdialog"
      class={["alert-dialog" | List.wrap(@class)]}
      aria-modal={(@open && "true") || "false"}
      aria-labelledby={"#{@id}-title"}
      aria-describedby={"#{@id}-content"}
      open={@open}
      phx-mounted={@open && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      {@rest}
    >
      <.focus_wrap
        id={"#{@id}-container"}
        class="alert-dialog-container"
        phx-window-keydown={@dismissable && JS.exec("data-cancel", to: "##{@id}")}
        phx-key={@dismissable && "escape"}
        phx-click-away={@dismissable && JS.exec("data-cancel", to: "##{@id}")}
      >
        <section>
          <header>
            <button
              :if={@dismissable}
              href="#"
              class="alert-dialog-close"
              aria-label={@close_label}
              phx-click={JS.exec("data-cancel", to: "##{@id}")}
            >
              <%= render_slot(@close) %>
              <span :if={@close == []}>close</span>
            </button>
            <h2 id={"#{@id}-title"}><%= render_slot(@title) %></h2>
          </header>
          <div id={"#{@id}-content"} class="alert-dialog-content">
            <%= render_slot(@inner_block) %>
          </div>
          <footer :if={@footer != []}>
            <%= render_slot(@footer) %>
          </footer>
        </section>
      </.focus_wrap>
    </dialog>
    """
  end

  @doc """
  The app bar is typically located at the top of the interface and provides
  access to key features and navigation options.

  ## Usage

  ```heex
  <Doggo.app_bar title="Page title">
    <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
      <Doggo.icon><Lucideicons.menu aria-hidden /></Doggo.icon>
    </:navigation>
    <:action label="Search" on_click={JS.push("search")}>
      <Doggo.icon><Lucideicons.search aria-hidden /></Doggo.icon>
    </:action>
    <:action label="Like" on_click={JS.push("like")}>
      <Doggo.icon><Lucideicons.heart aria-hidden /></Doggo.icon>
    </:action>
  </Doggo.app_bar>
  ```
  """
  @doc type: :navigation
  @doc since: "0.1.0"

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

    attr :on_click, :any,
      required: true,
      doc: "Event name or `Phoenix.LiveView.JS` command."
  end

  slot :action, doc: "Slot for action buttons right of the title." do
    attr :label, :string, required: true

    attr :on_click, :any,
      required: true,
      doc: "Event name or `Phoenix.LiveView.JS` command."
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
  Renders a navigation that sticks to the bottom of the screen.

  ## Example

  ```heex
  <Doggo.bottom_navigation current_value={@view}>
    <:item
      label="Profile"
      navigate={~p"/pets/\#{@pet}"}
      value={Profile}
    >
      <Lucideicons.user aria-hidden="true" />
    </:item>
    <:item
      label="Appointments"
      navigate={~p"/pets/\#{@pet}/appointments"}
      value={Appointments}
    >
      <Lucideicons.calendar_days aria-hidden="true" />
    </:item>
    <:item
      label="Messages"
      navigate={~p"/pets/\#{@pet}/messages"}
      value={Messages}
    >
      <Lucideicons.mails aria-hidden="true" />
    </:item>
  </Doggo.bottom_navigation>
  ```
  """
  @doc type: :navigation
  @doc since: "0.3.0"

  attr :label, :string,
    default: nil,
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
    The current value used to compare the item values with. This could be the
    current LiveView module, or the live action.
    """

  attr :hide_labels, :boolean,
    default: false,
    doc: """
    Hides the labels of the individual navigation items.
    """

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :item,
    required: true,
    doc: """
    Slot for the navigation items. The inner content should be used to render an
    icon.
    """ do
    attr :label, :string,
      doc: """
      Required label for the navigation items. The item labels can be visually
      hidden with the `hide_labels` attribute on the component.
      """

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

  def bottom_navigation(assigns) do
    ~H"""
    <nav
      aria-label={@label}
      class={["bottom-navigation" | List.wrap(@class)]}
      {@rest}
    >
      <ul>
        <li :for={item <- @item}>
          <.link
            href={item[:href]}
            navigate={item[:navigate]}
            patch={item[:patch]}
            aria-current={@current_value in List.wrap(item.value) && "page"}
            aria-label={item.label}
          >
            <span class="icon"><%= render_slot(item) %></span>
            <span :if={!@hide_labels}><%= item.label %></span>
          </.link>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders a carousel for presenting a sequence of items, such as images or text.

  > #### In Development {: .warning}
  >
  > The necessary JavaScript for making this component fully functional and
  > accessible will be added in a future version.
  >
  > **Missing features**
  >
  > - Handle previous/next buttons
  > - Handle pagination tabs
  > - Auto rotation
  > - Disable auto rotation when controls are used
  > - Disable previous/next button on first/last item.
  > - Focus management and keyboard support for pagination

  ## Example

  ```heex
  <Doggo.carousel label="Our Dogs">
    <:previous label="Previous Slide">
      <Heroicons.chevron_left />
    </:previous>
    <:next label="Next Slide">
      <Heroicons.chevron_right />
    </:next>
    <:item label="1 of 3">
      <Doggo.image
        src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
        alt="A dog wearing a colorful poncho walks down a fashion show runway."
        ratio={{16, 9}}
      />
    </:item>
    <:item label="2 of 3">
      <Doggo.image
        src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
        alt="A dog dressed in a sumptuous, baroque-style costume, complete with jewels and intricate embroidery, parades on an ornate runway at a luxurious fashion show, embodying opulence and grandeur."
        ratio={{16, 9}}
      />
    </:item>
    <:item label="3 of 3">
      <Doggo.image
        src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
        alt="A dog adorned in a lavish, flamboyant outfit, including a large feathered hat and elaborate jewelry, struts confidently down a luxurious fashion show runway, surrounded by bright lights and an enthusiastic audience."
        ratio={{16, 9}}
      />
    </:item>
  </Doggo.carousel>
  ```
  """
  @doc type: :component
  @doc since: "0.5.0"

  attr :id, :string, required: true

  attr :label, :string,
    default: nil,
    doc: """
    A accessibility label for the carousel. Set as `aria-label` attribute.

    You should ensure that either the `label` or the `labelledby` attribute is
    set.
    """

  attr :labelledby, :string,
    default: nil,
    doc: """
    The DOM ID of an element that labels this carousel.

    Example:

    ```html
    <h3 id="dog-carousel-label">Our Dogs</h3>
    <.carousel labelledby="dog-carousel-label"></.carousel>
    ```

    You should ensure that either the `label` or the `labelledby` attribute is
    set.
    """

  attr :carousel_roledescription, :string,
    default: "carousel",
    doc: """
    Sets the `aria-roledescription` attribute to describe the region as a
    carousel. This value should be translated to the language in which the rest
    of the page is displayed.
    """

  attr :slide_roledescription, :string,
    default: "slide",
    doc: """
    Sets the `aria-roledescription` attribute to describe a slide. This value
    should be translated to the language in which the rest of the page is
    displayed.
    """

  attr :pagination, :boolean, default: false
  attr :pagination_label, :string, default: "Slides"

  attr :pagination_slide_label, :any,
    default: &Doggo.slide_label/1,
    doc: """
    1-arity function that takes the slide number as an argument and returns the
    aria label for the slide as used in the pagination buttons.
    """

  attr :auto_rotation, :boolean, default: false

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block,
    required: true,
    doc: """
    Place the `carousel_item/1` component here.
    """

  slot :previous do
    attr :label, :string
  end

  slot :next do
    attr :label, :string
  end

  slot :item, required: true do
    attr :label, :string,
      doc: """
      Aria label for the slide, e.g. "1 of 5".
      """
  end

  def carousel(assigns) do
    ensure_label!(assigns, "Doggo.carousel", "Our Dogs")

    ~H"""
    <section
      id={@id}
      class={["carousel" | List.wrap(@class)]}
      aria-label={@label}
      aria-labelledby={@labelledby}
      aria-roledescription={@carousel_roledescription}
      {@rest}
    >
      <div class="carousel-inner">
        <div class="carousel-controls">
          <button
            :for={previous <- @previous}
            type="button"
            class="carousel-previous"
            aria-controls={"#{@id}-items"}
            aria-label={previous.label}
          >
            <%= render_slot(previous) %>
          </button>
          <button
            :for={next <- @next}
            type="button"
            class="carousel-next"
            aria-controls={"#{@id}-items"}
            aria-label={next.label}
          >
            <%= render_slot(next) %>
          </button>
          <div :if={@pagination} class="carousel-pagination">
            <div role="tablist" aria-label={@pagination_label}>
              <button
                :for={{_, index} <- Enum.with_index(@item, 1)}
                type="button"
                role="tab"
                aria-label={@pagination_slide_label.(index)}
                aria-controls={"#{@id}-item-#{index}"}
              >
                <span><span></span></span>
              </button>
            </div>
          </div>
        </div>
        <div
          id={"#{@id}-items"}
          class="carousel-items"
          aria-live={if @auto_rotation, do: "off", else: "polite"}
        >
          <div
            :for={{item, index} <- Enum.with_index(@item, 1)}
            id={"#{@id}-item-#{index}"}
            class="carousel-item"
            role="group"
            aria-roledescription={@slide_roledescription}
            aria-label={item.label}
          >
            <%= render_slot(item) %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  @doc false
  def slide_label(n), do: "Slide #{n}"

  @doc """
  Renders a text input with a popup that allows users to select a value from
  a list of suggestions.

  > #### In Development {: .warning}
  >
  > The necessary JavaScript for making this component fully functional and
  > accessible will be added in a future version.
  >
  > **Missing features**
  >
  > - Showing/hiding suggestions
  > - Filtering suggestions
  > - Selecting a value
  > - Focus management
  > - Keyboard support

  ## Example

  With simple values:

  ```heex
  <Doggo.combobox
    id="dog-breed-selector"
    name="breed"
    list_label="Dog breeds"
    options={[
      "Labrador Retriever",
      "German Shepherd",
      "Golden Retriever",
      "French Bulldog",
      "Bulldog"
    ]}
  />
  ```

  With label/value pairs:

  ```heex
  <Doggo.combobox
    id="dog-breed-selector"
    name="breed"
    list_label="Dog breeds"
    options={[
      {"Labrador Retriever", "labrador"},
      {"German Shepherd", "german_shepherd"},
      {"Golden Retriever", "golden_retriever"},
      {"French Bulldog", "french_bulldog"},
      {"Bulldog", "bulldog"}
    ]}
  />
  ```

  With label/value/description tuples:

  ```heex
  <Doggo.combobox
    id="dog-breed-selector"
    name="breed"
    list_label="Dog breeds"
    options={[
      {"Labrador Retriever", "labrador", "Friendly and outgoing"},
      {"German Shepherd", "german_shepherd", "Confident and smart"},
      {"Golden Retriever", "golden_retriever", "Intelligent and friendly"},
      {"French Bulldog", "french_bulldog", "Adaptable and playful"},
      {"Bulldog", "bulldog", "Docile and willful"}
    ]}
  />
  ```
  """
  @doc type: :component
  @doc since: "0.5.0"

  attr :id, :string, required: true, doc: "Sets the DOM ID for the input."
  attr :name, :string, required: true, doc: "Sets the name for the text input."

  attr :value, :string,
    default: nil,
    doc: """
    The current input value. The display value for the text input is derived
    by finding the given value in the list of options.
    """

  attr :list_label, :string,
    required: true,
    doc: """
    Sets the aria label for the list box. For example, if the combobox allows
    the user to select a country, the list label could be `"Countries"`. The
    value should start with an uppercase letter and be localized.
    """

  attr :options, :list,
    required: true,
    doc: """
    A list of available options.

    - If a list of primitive values is passed, each item serves as both the
      label and the input value.
    - If a list of 2-tuples is passed, the first tuple element serves as label
      and the second element serves as input value.
    - If a list of 3-tuples is passed, the third tuple element serves as
      an additional description.
    """

  attr :rest, :global, doc: "Any additional HTML attributes."

  def combobox(%{name: name, value: value, options: options} = assigns) do
    search_name =
      if String.ends_with?(name, "]"),
        do: "#{String.slice(name, 0..-2//1)}_search]",
        else: name <> "_search"

    search_value =
      Enum.find_value(options, fn
        ^value -> value
        {label, ^value} -> label
        {label, ^value, _} -> label
        _ -> nil
      end)

    assigns =
      assign(assigns, search_name: search_name, search_value: search_value)

    ~H"""
    <div class="combobox" {@rest}>
      <div role="group">
        <input
          id={@id}
          type="text"
          role="combobox"
          name={@search_name}
          value={@search_value}
          aria-autocomplete="list"
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
          autocomplete="off"
        />
        <button
          id={"#{@id}-button"}
          tabindex="-1"
          aria-label={@list_label}
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
        >
          ▼
        </button>
      </div>
      <ul id={"#{@id}-listbox"} role="listbox" aria-label={@list_label} hidden>
        <.combobox_option :for={option <- @options} option={option} />
      </ul>
      <input type="hidden" id={"#{@id}-value"} name={@name} value={@value} />
    </div>
    """
  end

  defp combobox_option(%{option: {label, value}} = assigns) do
    assigns = assign(assigns, label: label, value: value, option: nil)

    ~H"""
    <li role="option" data-value={@value}>
      <span class="combobox-option-label"><%= @label %></span>
    </li>
    """
  end

  defp combobox_option(%{option: {label, value, description}} = assigns) do
    assigns =
      assign(assigns,
        label: label,
        value: value,
        description: description,
        option: nil
      )

    ~H"""
    <li role="option" data-value={@value}>
      <span class="combobox-option-label"><%= @label %></span>
      <span class="combobox-option-description"><%= @description %></span>
    </li>
    """
  end

  defp combobox_option(assigns) do
    ~H"""
    <li role="option" data-value={@option}>
      <span class="combobox-option-label"><%= @option %></span>
    </li>
    """
  end

  @doc """
  Renders a `DateTime` or `NaiveDateTime` in a `<time>` tag.

  ## Examples

  By default, the given value is formatted for display with `to_string/1`. This:

  ```heex
  <Doggo.datetime value={~U[2023-02-05 12:22:06.003Z]} />
  ```

  Will be rendered as:

  ```html
  <time datetime="2023-02-05T12:22:06.003Z">
    2023-02-05 12:22:06.003Z
  </time>
  ```

  You can also pass a custom formatter function. For example, if you are using
  [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
  application, you could do this:

  ```heex
  <Doggo.datetime
    value={~U[2023-02-05 14:22:06.003Z]}
    formatter={&MyApp.Cldr.DateTime.to_string!/1}
  />
  ```

  Which, depending on your locale, may be rendered as:

  ```html
  <time datetime="2023-02-05T14:22:06.003Z">
    Feb 2, 2023, 14:22:06 PM
  </time>
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

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

  ```heex
  <Doggo.date value={~D[2023-02-05]} />
  ```

  Will be rendered as:

  ```html
  <time datetime="2023-02-05">
    2023-02-05
  </time>
  ```

  You can also pass a custom formatter function. For example, if you are using
  [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
  application, you could do this:

  ```heex
  <Doggo.date
    value={~D[2023-02-05]}
    formatter={&MyApp.Cldr.Date.to_string!/1}
  />
  ```

  Which, depending on your locale, may be rendered as:

  ```html
  <time datetime="2023-02-05">
    Feb 2, 2023
  </time>
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

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

  ```heex
  <Doggo.time value={~T[12:22:06.003Z]} />
  ```

  Will be rendered as:

  ```html
  <time datetime="12:22:06.003">
    12:22:06.003
  </time>
  ```

  You can also pass a custom formatter function. For example, if you are using
  [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) in your
  application, you could do this:

  ```heex
  <Doggo.time
    value={~T[12:22:06.003]}
    formatter={&MyApp.Cldr.Time.to_string!/1}
  />
  ```

  Which, depending on your locale, may be rendered as:

  ```html
  <time datetime="14:22:06.003">
    14:22:06 PM
  </time>
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

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

  All slots are optional, and you can render any content in them. If you want
  to use the drawer as a sidebar, you can use the `vertical_nav/1` and
  `vertical_nav_section/1` components.

  ## Example

  Minimal example:

  ```heex
  <Doggo.drawer>
    <:main>Content</:main>
  </Doggo.drawer>
  ```

  With all slots:

  ```heex
  <Doggo.drawer>
    <:header>Doggo</:header>
    <:main>Content at the top</:main>
    <:footer>Content at the bottom</:footer>
  </Doggo.drawer>
  ```

  With navigation and sections:

  ```heex
  <Doggo.drawer>
    <:header>
      <.link navigate={~p"/"}>App</.link>
    </:header>
    <:main>
      <Doggo.vertical_nav label="Main">
        <:item>
          <.link navigate={~p"/dashboard"}>Dashboard</.link>
        </:item>
        <:item>
          <Doggo.vertical_nav_nested>
            <:title>Content</:title>
            <:item current_page>
              <.link navigate={~p"/posts"}>Posts</.link>
            </:item>
            <:item>
              <.link navigate={~p"/comments"}>Comments</.link>
            </:item>
          </Doggo.vertical_nav_nested>
        </:item>
      </.vertical_nav>
      <Doggo.vertical_nav_section>
        <:title>Search</:title>
        <:item><input type="search" placeholder="Search" /></:item>
      </Doggo.vertical_nav_section>
    </:main>
    <:footer>
      <Doggo.vertical_nav label="User menu">
        <:item>
          <.link navigate={~p"/settings"}>Settings</.link>
        </:item>
        <:item>
          <.link navigate={~p"/logout"}>Logout</.link>
        </:item>
      </Doggo.vertical_nav>
    </:footer>
  </Doggo.drawer>
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :header, doc: "Optional slot for the brand name or logo."

  slot :main,
    doc: """
    Slot for content that is rendered after the brand, at the start of the
    side bar.
    """

  slot :footer,
    doc: """
    Slot for content that is rendered at the end of the drawer, potentially
    pinned to the bottom, if there is enough room.
    """

  def drawer(assigns) do
    ~H"""
    <aside class={["drawer" | List.wrap(@class)]} {@rest}>
      <div :if={@header != []} class="drawer-header">
        <%= render_slot(@header) %>
      </div>
      <div :if={@main != []} class="drawer-main">
        <%= render_slot(@main) %>
      </div>
      <div :if={@footer != []} class="drawer-footer">
        <%= render_slot(@footer) %>
      </div>
    </aside>
    """
  end

  @doc """
  Renders a vertical navigation menu.

  It is commonly placed within drawers or sidebars.

  For hierarchical menu structures, use `vertical_nav_nested/1` within the
  `:item` slot.

  To include sections in your drawer or sidebar that are not part of the
  navigation menu (like informational text or a site search), use the
  `vertical_nav_section/1` component.

  ## Example

  ```heex
  <Doggo.vertical_nav label="Main">
    <:item>
      <.link navigate={~p"/dashboard"}>Dashboard</.link>
    </:item>
    <:item>
      <Doggo.vertical_nav_nested>
        <:title>Content</:title>
        <:item current_page>
          <.link navigate={~p"/posts"}>Posts</.link>
        </:item>
        <:item>
          <.link navigate={~p"/comments"}>Comments</.link>
        </:item>
      </Doggo.vertical_nav_nested>
    </:item>
  </Doggo.vertical_nav>
  ```
  """
  @doc type: :navigation
  @doc since: "0.5.0"

  attr :id, :string, default: nil
  attr :label, :string, required: true

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :title, doc: "An optional slot for the title of the menu."

  slot :item, required: true, doc: "Items" do
    attr :class, :string
    attr :current_page, :boolean
  end

  def vertical_nav(assigns) do
    ~H"""
    <nav id={@id} aria-label={@label} {@rest}>
      <div :if={@title != []} class="drawer-nav-title">
        <%= render_slot(@title) %>
      </div>
      <ul>
        <li
          :for={item <- @item}
          class={item[:class]}
          aria-current={Map.get(item, :current_page, false) && "page"}
        >
          <%= render_slot(item) %>
        </li>
      </ul>
    </nav>
    """
  end

  @doc """
  Renders nested navigation items within the `:item` slot of the
  `vertical_nav/1` component.

  ## Example

  ```heex
  <Doggo.vertical_nav label="Main">
    <:item>
      <Doggo.vertical_nav_nested>
        <:title>Content</:title>
        <:item current_page>
          <.link navigate={~p"/posts"}>Posts</.link>
        </:item>
        <:item>
          <.link navigate={~p"/comments"}>Comments</.link>
        </:item>
      </Doggo.vertical_nav_nested>
    </:item>
  </Doggo.vertical_nav>
  ```
  """
  @doc type: :navigation
  @doc since: "0.5.0"

  attr :id, :string, required: true

  slot :title, doc: "An optional slot for the title of the nested menu section."

  slot :item, required: true, doc: "Items" do
    attr :class, :string
    attr :current_page, :boolean
  end

  def vertical_nav_nested(assigns) do
    ~H"""
    <div :if={@title != []} id={"#{@id}-title"} class="drawer-nav-title">
      <%= render_slot(@title) %>
    </div>
    <ul id={@id} aria-labelledby={@title != [] && "#{@id}-title"}>
      <li
        :for={item <- @item}
        class={item[:class]}
        aria-current={Map.get(item, :current_page, false) && "page"}
      >
        <%= render_slot(item) %>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a section within a sidebar or drawer that contains one or more
  items which are not navigation links.

  To render navigation links, use `vertical_nav/1` instead.

  ## Example

  ```heex
  <Doggo.vertical_nav_section>
    <:title>Search</:title>
    <:item><input type="search" placeholder="Search" /></:item>
  </Doggo.vertical_nav_section>
  ```
  """
  @doc type: :navigation
  @doc since: "0.5.0"

  attr :id, :string, required: true

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :title, doc: "An optional slot for the title of the section."

  slot :item, required: true, doc: "Items" do
    attr :class, :any,
      doc: "Additional CSS classes. Can be a string or a list of strings."
  end

  def vertical_nav_section(assigns) do
    ~H"""
    <div
      id={@id}
      class={["drawer-section" | List.wrap(@class)]}
      aria-labelledby={@title != [] && "#{@id}-title"}
      {@rest}
    >
      <div :if={@title != []} id={"#{@id}-title"} class="drawer-section-title">
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

  ```heex
  <Doggo.flash_group flash={@flash} />
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

  attr :flash, :map, required: true, doc: "The map of flash messages."

  attr :info_title, :string,
    default: "Success",
    doc: "Alert title for flash messages with level `:info`."

  attr :error_title, :string,
    default: "Error",
    doc: "Alert title for flash messages with level `:error`."

  attr :client_error_title, :string,
    default: "Disconnected",
    doc: "Alert title for disconnection errors."

  attr :client_error_msg, :string,
    default: "Attempting to reconnect.",
    doc: "Alert message for disconnection errors."

  attr :server_error_title, :string,
    default: "Error",
    doc: "Alert title for server errors."

  attr :server_error_msg, :string,
    default: "Please wait while we get back on track.",
    doc: "Alert message for server errors."

  attr :id, :string, default: "flash-group", doc: "An ID for the container."
  attr :class, :any, default: nil, doc: "An optional class name."
  attr :rest, :global, doc: "Any additional HTML attributes."

  def flash_group(assigns) do
    ~H"""
    <div class={["flash-group" | List.wrap(@class)]} id={@id} {@rest}>
      <.alert
        :if={msg = Phoenix.Flash.get(@flash, :info)}
        id={"#{@id}-flash-info"}
        level={:info}
        title={@info_title}
        on_close={clear_flash(:info)}
      >
        <%= msg %>
      </.alert>
      <.alert
        :if={msg = Phoenix.Flash.get(@flash, :error)}
        id={"#{@id}-flash-error"}
        level={:danger}
        title={@error_title}
        on_close={clear_flash(:error)}
      >
        <%= msg %>
      </.alert>
      <.alert
        id={"#{@id}-client-error"}
        level={:danger}
        title={@client_error_title}
        phx-disconnected={JS.show(to: ".phx-client-error ##{@id}-client-error")}
        phx-connected={JS.hide(to: "##{@id}-client-error")}
        hidden
      >
        <%= @client_error_msg %>
      </.alert>
      <.alert
        id={"#{@id}-server-error"}
        level={:danger}
        title={@server_error_title}
        phx-disconnected={JS.show(to: ".phx-server-error ##{@id}-server-error")}
        phx-connected={JS.hide(to: "##{@id}-server-error")}
        hidden
      >
        <%= @server_error_msg %>
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

  For supplementary information that doesn't require the user's immediate
  attention, use `callout/1` instead.

  ## Examples

  Minimal example:

  ```heex
  <Doggo.alert id="some-alert"></Doggo.alert>
  ```

  With title, icon and level:

  ```heex
  <Doggo.alert id="some-alert" level={:info} title="Info">
    message
    <:icon><Heroicon.light_bulb /></:icon>
  </Doggo.alert>
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

  attr :id, :string, required: true

  attr :level, :atom,
    values: [:info, :success, :warning, :danger],
    default: :info,
    doc: "Semantic level of the alert."

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
      aria-labelledby={@title && "#{@id}-title"}
      class={[variant_class(@level) | List.wrap(@class)]}
      {@rest}
    >
      <div :if={@icon != []} class="alert-icon">
        <%= render_slot(@icon) %>
      </div>
      <div class="alert-body">
        <div :if={@title} id={"#{@id}-title"} class="alert-title">
          <%= @title %>
        </div>
        <div class="alert-message"><%= render_slot(@inner_block) %></div>
      </div>
      <button :if={@on_close} phx-click={@on_close}>
        <%= @close_label %>
      </button>
    </div>
    """
  end

  @doc """
  Renders profile picture, typically to represent a user.

  ## Example

  Minimal example with only the `src` attribute:

  ```heex
  <Doggo.avatar src="avatar.png" />
  ```

  Render avatar as a circle:

  ```heex
  <Doggo.avatar src="avatar.png" circle />
  ```

  Use a placeholder image in case the avatar is not set:

  ```heex
  <Doggo.avatar src={@user.avatar_url} placeholder={{:src, "fallback.png"}} />
  ```

  Render an text as the placeholder value:

  ```heex
  <Doggo.avatar src={@user.avatar_url} placeholder="A" />
  ```

  """
  @doc type: :component
  @doc since: "0.3.0"

  attr :src, :any,
    default: nil,
    doc: """
    The URL of the avatar image. If `nil`, the component will use the value
    provided in the placeholder attribute.
    """

  attr :placeholder, :any,
    default: nil,
    doc: """
    Fallback value to render in case the `src` attribute is `nil`.

    - For a placeholder image, pass a tuple `{:src, url}`.
    - For other types of placeholder content, such as text initials or inline
      SVG, pass the content directly. The component will render this content
      as-is.

    If the placeholder value is set to `nil`, no avatar will be rendered if the
    `src` is `nil`.
    """

  attr :alt, :string,
    default: "",
    doc: """
    Use alt text to identify the individual in an avatar if their name or
    identifier isn't otherwise provided in adjacent text. In contexts where
    the user's name or identifying information is already displayed alongside
    the avatar, use `alt=""` (the default) to avoid redundancy and treat the
    avatar as a decorative element for screen readers.
    """

  attr :size, :atom, values: @sizes, default: :normal
  attr :circle, :boolean, default: false
  attr :loading, :string, values: ["eager", "lazy"], default: "lazy"

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  def avatar(%{src: nil, placeholder: nil} = assigns), do: ~H""

  def avatar(assigns) do
    ~H"""
    <div
      class={
        ["avatar", size_class(@size), @circle && shape_class(:circle)] ++
          List.wrap(@class)
      }
      {@rest}
    >
      <.inner_avatar
        src={@src}
        placeholder={@placeholder}
        alt={@alt}
        loading={@loading}
      />
    </div>
    """
  end

  defp inner_avatar(%{src: src} = assigns) when is_binary(src) do
    ~H"""
    <img src={@src} alt={@alt} loading={@loading} />
    """
  end

  defp inner_avatar(%{placeholder: {:src, src}} = assigns)
       when is_binary(src) do
    assigns = assign(assigns, :src, src)

    ~H"""
    <img src={@src} alt={@alt} loading={@loading} />
    """
  end

  defp inner_avatar(assigns) do
    ~H"""
    <span><%= @placeholder %></span>
    """
  end

  @doc """
  Use the callout to highlight supplementary information related to the main
  content.

  For information that needs immediate attention of the user, use `alert/1`
  instead.

  ## Example

  Standard callout:

  ```heex
  <Doggo.callout title="Dog Care Tip">
    <p>Regular exercise is essential for keeping your dog healthy and happy.</p>
  </Doggo.callout>
  ```

  Callout with an icon:

  ```heex
  <Doggo.callout title="Fun Dog Fact">
    <:icon><Heroicons.information_circle /></:icon>
    <p>
      Did you know? Dogs have a sense of time and can get upset when their
      routine is changed.
    </p>
  </Doggo.callout>
  ```
  """
  @doc type: :component
  @doc since: "0.3.0"

  attr :id, :string, required: true
  attr :variant, :atom, values: @variants, default: :info
  attr :title, :string, default: nil, doc: "An optional title."

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."

  slot :inner_block, required: true, doc: "The main content of the alert."
  slot :icon, doc: "Optional slot to render an icon."

  def callout(assigns) do
    ~H"""
    <aside
      id={@id}
      class={["callout", variant_class(@variant)] ++ List.wrap(@class)}
      aria-labelledby={@title && "#{@id}-title"}
      {@rest}
    >
      <div :if={@icon != []} class="callout-icon">
        <%= render_slot(@icon) %>
      </div>
      <div class="callout-body">
        <div :if={@title} id={"#{@id}-title"} class="callout-title">
          <%= @title %>
        </div>
        <div class="callout-message"><%= render_slot(@inner_block) %></div>
      </div>
    </aside>
    """
  end

  @doc """
  Renders a card in an `article` tag, typically used repetitively in a grid or
  flex box layout.

  ## Usage

  ```heex
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
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

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

  ```heex
  <Doggo.fallback value={@some_value} />
  ```

  Apply a formatter function to `@some_value` if it is not `nil`:

  ```heex
  <Doggo.fallback value={@some_value} formatter={&format_date/1} />
  ```

  Set a custom placeholder and text for screen readers:

  ```heex
  <Doggo.fallback
    value={@some_value}
    placeholder="n/a"
    accessibility_text="not available"
  />
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

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

  ```heex
  <Doggo.frame ratio={{4, 3}}>
    <img src="image.png" alt="An example image illustrating the usage." />
  </Doggo.frame>
  ```

  Rendering an image as a circle.

  ```heex
  <Doggo.frame circle>
    <img src="image.png" alt="An example image illustrating the usage." />
  </Doggo.frame>
  ```
  """
  @doc type: :component
  @doc since: "0.2.0"

  attr :ratio, :any, values: [nil | @ratios], default: nil
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

  ```heex
  <Doggo.icon label="report bug"><Heroicons.bug_ant /></.icon>
  ```

  To display the text visibly:

  ```heex
  <Doggo.icon label="report bug" label_placement={:right}>
    <Heroicons.bug_ant />
  </Doggo.icon>
  ```

  > #### aria-hidden {: .info}
  >
  > Not all icon libraries set the `aria-hidden` attribute by default. Always
  > make sure that it is set on the `<svg>` element that the library renders.
  """
  @doc type: :component
  @doc since: "0.1.0"

  slot :inner_block, doc: "Slot for the SVG element.", required: true

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

  attr :size, :atom, values: @sizes, default: :normal

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
      {@rest}
    >
      <%= render_slot(@inner_block) %>
      <span :if={@label} class={@label_placement == :hidden && "is-visually-hidden"}>
        <%= @label %>
      </span>
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

  ```heex
  <Doggo.icon name="arrow-left" label="Go back" />
  ```

  To display the text visibly:

  ```heex
  <Doggo.icon name="arrow-left" label="Go back" label_placement={:right} />
  ```
  """
  @doc type: :component
  @doc since: "0.1.0"

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

  attr :size, :atom, values: @sizes, default: :normal

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
      {@rest}
    >
      <svg aria-hidden="true"><use href={"#{@sprite_url}##{@name}"} /></svg>
      <span :if={@label} class={@label_placement == :hidden && "is-visually-hidden"}>
        <%= @label %>
      </span>
    </span>
    """
  end

  @doc """
  Renders an image with an optional caption.

  ## Example

  ```heex
  <Doggo.image
    src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
    alt="A dog wearing a colorful poncho walks down a fashion show runway."
    ratio={{16, 9}}
  >
    <:caption>
      Spotlight on canine couture: A dog fashion show where four-legged models
      dazzle the runway with the latest in pet apparel.
    </:caption>
  </Doggo.image>
  ```
  """
  @doc type: :component
  @doc since: "0.2.0"

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
  attr :ratio, :any, values: [nil | @ratios], default: nil

  attr :class, :any,
    default: [],
    doc: "Additional CSS classes. Can be a string or a list of strings."

  attr :rest, :global, doc: "Any additional HTML attributes."
  slot :caption

  def image(assigns) do
    ~H"""
    <figure class={["image" | List.wrap(@class)]} {@rest}>
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

  ```heex
  <Doggo.input field={@form[:name]} gettext={MyApp.Gettext} />
  ```

  ## Label positioning

  The component does not provide an attribute to modify label positioning
  directly. Instead, label positioning should be handled with CSS. If your
  application requires different label positions, such as horizontal and
  vertical layouts, it is recommended to add a modifier class to the form.

  For example, the default style could position labels above inputs. To place
  labels to the left of the inputs in a horizontal form layout, you can add an
  `is-horizontal` class to the form:

  ```heex
  <.form class="is-horizontal">
    <!-- inputs -->
  </.form>
  ```

  Then, in your CSS, apply the necessary styles to the `.field` class within
  forms having the `is-horizontal` class:

  ```css
  form.is-horizontal .field {
    // styles to position label left of the input
  }
  ```

  The component has a `hide_label` attribute to visually hide labels while still
  making them accessible to screen readers. If all labels within a form need to
  be visually hidden, it may be more convenient to define a
  `.has-visually-hidden-labels` modifier class for the `<form>`.

  ```heex
  <.form class="has-visually-hidden-labels">
    <!-- inputs -->
  </.form>
  ```

  Ensure to take checkbox and radio labels into consideration when writing the
  CSS styles.

  ## Examples

  ```heex
  <Doggo.input field={@form[:name]} />
  ```

  ```heex
  <Doggo.input field={@form[:email]} type="email" />
  ```

  ### Radio group and checkbox group

  The `radio-group` and `checkbox-group` types allow you to easily render groups
  of radio buttons or checkboxes with a single component invocation. The
  `options` attribute is required for these types and has the same format as
  the options for the `select` type, except that options may not be nested.

  ```heex
  <Doggo.input
    field={@form[:email]}
    type="checkbox-group"
    label="Cuisine"
    options={[
      {"Mexican", "mexican"},
      {"Japanese", "japanese"},
      {"Libanese", "libanese"}
    ]}
  />
  ```

  Note that the `checkbox-group` type renders an additional hidden input with
  an empty value before the checkboxes. This ensures that a value exists in case
  all checkboxes are unchecked. Consequently, the resulting list value includes
  an extra empty string. While `Ecto.Changeset.cast/3` filters out empty strings
  in array fields by default, you may need to handle the additional empty string
  manual in other contexts.
  """
  @doc type: :form
  @doc since: "0.1.0"

  attr :id, :any, default: nil
  attr :name, :any

  attr :label, :string,
    default: nil,
    doc: """
    Required for all types except `"hidden"`.
    """

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

  attr :on_text, :string,
    default: "On",
    doc: "The state text for a switch when on."

  attr :off_text, :string,
    default: "Off",
    doc: "The state text for a switch when off."

  attr :prompt, :string,
    default: nil,
    doc: "An optional prompt for select elements."

  attr :options, :list,
    default: nil,
    doc: """
    A list of options.

    This attribute is supported for the following types:

    - `"select"`
    - `"radio-group"`
    - `"checkbox-group"`
    - other text types, date and time types, and the `"range"` type

    If this attribute is set for types other than select, radio, and checkbox,
    a [datalist](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/datalist)
    is rendered for the input.

    See `Phoenix.HTML.Form.options_for_select/2` for the format. Note that only
    the select supports nested options.
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

  attr :required_text, :atom,
    doc: """
    The presentational text or symbol to be added to labels of required inputs.

    This option can also be set globally:

        config :doggo, required_text: "required"
    """

  attr :required_title, :atom,
    doc: """
    The `title` attribute for the `required_text`.

    This option can also be set globally:

        config :doggo, required_title: "required"
    """

  slot :description, doc: "A field description to render underneath the input."

  slot :addon_left,
    doc: """
    Can be used to render an icon left in the input. Only supported for
    single-line inputs.
    """

  slot :addon_right,
    doc: """
    Can be used to render an icon left in the input. Only supported for
    single-line inputs.
    """

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    gettext_module =
      Map.get(assigns, :gettext, Application.get_env(:doggo, :gettext))

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign_new(
      :errors,
      fn -> Enum.map(errors, &translate_error(&1, gettext_module)) end
    )
    |> assign_new(
      :required_text,
      fn -> Application.get_env(:doggo, :required_text, "*") end
    )
    |> assign_new(
      :required_title,
      fn -> Application.get_env(:doggo, :required_title, "required") end
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
    <div class={["field", field_error_class(@errors)]}>
      <.label required={@validations[:required] || false} class="checkbox">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          name={@name}
          id={@id}
          value={@checked_value}
          checked={@checked}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        />
        <%= @label %>
      </.label>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "checkbox-group"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <fieldset class="checkbox-group">
        <legend>
          <%= @label %>
          <.required_mark
            :if={@validations[:required]}
            text={@required_text}
            title={@required_title}
          />
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
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "radio-group"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <fieldset class="radio-group">
        <legend>
          <%= @label %>
          <.required_mark
            :if={@validations[:required]}
            text={@required_text}
            title={@required_title}
          />
        </legend>
        <div>
          <Doggo.Components.radio
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
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "switch"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["field", field_error_class(@errors)]}>
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
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        />
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
      </.label>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        required_title={@required_title}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <div class={["select", @multiple && "is-multiple"]}>
        <select
          name={@name}
          id={@id}
          multiple={@multiple}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        >
          <option :if={@prompt} value=""><%= @prompt %></option>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
      </div>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["field", field_error_class(@errors)]}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        required_title={@required_title}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <textarea
        name={@name}
        id={@id}
        aria-describedby={input_aria_describedby(@id, @description)}
        aria-errormessage={input_aria_errormessage(@id, @errors)}
        aria-invalid={@errors != [] && "true"}
        {@validations}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
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
    <div class={["field", field_error_class(@errors)]}>
      <.label
        for={@id}
        required={@validations[:required] || false}
        required_text={@required_text}
        required_title={@required_title}
        visually_hidden={@hide_label}
      >
        <%= @label %>
      </.label>
      <div class={[
        "input-wrapper",
        @addon_left != [] && "has-addon-left",
        @addon_right != [] && "has-addon-right"
      ]}>
        <input
          name={@name}
          id={@id}
          list={@options && "#{@id}_datalist"}
          type={@type}
          value={normalize_value(@type, @value)}
          aria-describedby={input_aria_describedby(@id, @description)}
          aria-errormessage={input_aria_errormessage(@id, @errors)}
          aria-invalid={@errors != [] && "true"}
          {@validations}
          {@rest}
        />
        <div :if={@addon_left != []} class="input-addon-left">
          <%= render_slot(@addon_left) %>
        </div>
        <div :if={@addon_right != []} class="input-addon-right">
          <%= render_slot(@addon_right) %>
        </div>
      </div>
      <datalist :if={@options} id={"#{@id}_datalist"}>
        <.option :for={option <- @options} option={option} />
      </datalist>
      <.field_errors for={@id} errors={@errors} />
      <.field_description :if={@description != []} for={@id}>
        <%= render_slot(@description) %>
      </.field_description>
    </div>
    """
  end

  defp option(%{option: {label, value}} = assigns) do
    assigns = assign(assigns, label: label, value: value)

    ~H"""
    <option value={@value}><%= @label %></option>
    """
  end

  defp option(%{option: _} = assigns) do
    ~H"""
    <option value={@option}><%= @option %></option>
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

  @doc false
  def input_aria_describedby(_, []), do: nil
  def input_aria_describedby(id, _), do: field_description_id(id)

  @doc false
  def input_aria_errormessage(_, []), do: nil
  def input_aria_errormessage(id, _), do: field_errors_id(id)

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
        aria-describedby={input_aria_describedby(@id, @description)}
        aria-errormessage={input_aria_errormessage(@id, @errors)}
        aria-invalid={@errors != [] && "true"}
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

  @doc false
  def checked?(option, value) when is_list(value) do
    Phoenix.HTML.html_escape(option) in Enum.map(
      value,
      &Phoenix.HTML.html_escape/1
    )
  end

  def checked?(option, value) do
    Phoenix.HTML.html_escape(option) == Phoenix.HTML.html_escape(value)
  end

  @doc """
  Renders the label for an input.

  ## Example

  ```heex
  <Doggo.label for="name" required>
    Name
  </Doggo.label>
  ```
  """
  @doc type: :form
  @doc since: "0.1.0"

  attr :for, :string, default: nil, doc: "The ID of the input."

  attr :required, :boolean,
    default: false,
    doc: "If set to `true`, a 'required' mark is rendered."

  attr :required_text, :any,
    default: "*",
    doc: """
    Sets the presentational text or symbol to mark an input as required.
    """

  attr :required_title, :any,
    default: "required",
    doc: """
    Sets the `title` attribute of the required mark.
    """

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
      <.required_mark :if={@required} title={@required_title} text={@required_text} />
    </label>
    """
  end

  attr :text, :string, default: "*"
  attr :title, :string, default: "required"

  # inputs are announced as required by screen readers if the `required`
  # attribute is set. This makes this mark purely visual. `aria-hidden="true"`
  # is added so that screen readers don't announce redundant information. The
  # title attribute has poor accessibility characteristics, but since this is
  # purely presentational, this is acceptable.
  # It is good practice to add a sentence explaining that fields marked with an
  # asterisk (*) are required to the form.
  # Alternatively, the word `required` might be used instead of an asterisk.
  defp required_mark(assigns) do
    ~H"""
    <span :if={@text} class="label-required" aria-hidden="true" title={@title}>
      <%= @text %>
    </span>
    """
  end

  @doc """
  Renders the errors for an input.

  ## Example

  ```heex
  <Doggo.field_errors for="name" errors={["too many characters"]} />
  ```
  """
  @doc type: :form
  @doc since: "0.1.0"

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

  ## Example

  ```heex
  <Doggo.field_description for="name">
    max. 100 characters
  </Doggo.field_description>
  ```
  """
  @doc type: :form
  @doc since: "0.1.0"

  attr :for, :string, required: true, doc: "The ID of the input."
  slot :inner_block, required: true

  def field_description(assigns) do
    ~H"""
    <div id={field_description_id(@for)} class="field-description">
      <%= render_slot(@inner_block) %>
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
      # credo:disable-for-next-line
      apply(Gettext, :dngettext, [
        gettext_module,
        "errors",
        msg,
        msg,
        count,
        opts
      ])
    else
      # credo:disable-for-next-line
      apply(Gettext, :dgettext, [gettext_module, "errors", msg, opts])
    end
  end

  @doc """
  Use the field group component to visually group multiple inputs in a form.

  This component is intended for styling purposes and does not provide semantic
  grouping. For semantic grouping of related form elements, use the `<fieldset>`
  and `<legend>` HTML elements instead.

  ## Examples

  Visual grouping of inputs:

  ```heex
  <Doggo.field_group>
    <Doggo.input field={@form[:given_name]} label="Given name" />
    <Doggo.input field={@form[:family_name]} label="Family name"/>
  </Doggo.field_group>
  ```

  Semantic grouping (for reference):

  ```heex
  <fieldset>
    <legend>Personal Information</legend>
    <Doggo.input field={@form[:given_name]} label="Given name" />
    <Doggo.input field={@form[:family_name]} label="Family name"/>
  </fieldset>
  ```
  """
  @doc type: :form
  @doc since: "0.3.0"

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

  ## Helpers

  @doc false
  def humanize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> humanize()
  end

  def humanize(s) when is_binary(s) do
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

  ## JS functions

  @doc """
  Hides the modal with the given ID.

  ## Example

  ```heex
  <.link phx-click={hide_modal("pet-modal")}>hide</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.remove_attribute("open", to: "##{id}")
    |> JS.set_attribute({"aria-modal", "false"}, to: "##{id}")
    |> JS.pop_focus()
  end

  @doc """
  Shows the modal with the given ID.

  ## Example

  ```heex
  <.link phx-click={show_modal("pet-modal")}>show</.link>
  ```
  """
  @doc type: :js
  @doc since: "0.1.0"

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.push_focus()
    |> JS.set_attribute({"open", "true"}, to: "##{id}")
    |> JS.set_attribute({"aria-modal", "true"}, to: "##{id}")
    |> JS.focus_first(to: "##{id}-content")
  end

  @doc """
  Shows the tab with the given index of the `tabs/1` component with the given
  ID.

  ## Example

      Doggo.show_tab("my-tabs", 2)
  """
  @doc type: :js
  @doc since: "0.5.0"

  def show_tab(js \\ %JS{}, id, index)
      when is_binary(id) and is_integer(index) do
    other_tabs = "##{id} [role='tab']:not(##{id}-tab-#{index})"
    other_panels = "##{id} [role='tabpanel']:not(##{id}-panel-#{index})"

    js
    |> JS.set_attribute({"aria-selected", "true"}, to: "##{id}-tab-#{index}")
    |> JS.set_attribute({"tabindex", "0"}, to: "##{id}-tab-#{index}")
    |> JS.remove_attribute("hidden", to: "##{id}-panel-#{index}")
    |> JS.set_attribute({"aria-selected", "false"}, to: other_tabs)
    |> JS.set_attribute({"tabindex", "-1"}, to: other_tabs)
    |> JS.set_attribute({"hidden", "hidden"}, to: other_panels)
  end

  @doc false
  def toggle_accordion_section(id, index)
      when is_binary(id) and is_integer(index) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"},
      to: "##{id}-trigger-#{index}"
    )
    |> JS.toggle_attribute({"hidden", "hidden"},
      to: "##{id}-section-#{index}"
    )
  end

  @doc false
  def toggle_disclosure(target_id) when is_binary(target_id) do
    %JS{}
    |> JS.toggle_attribute({"aria-expanded", "true", "false"})
    |> JS.toggle_attribute({"hidden", "hidden"}, to: "##{target_id}")
  end

  ## Modifier classes

  @doc """
  Takes a modifier attribute value and returns a CSS class name.

  This function is used as a default for the `class_name_fun` option.

  ## Example

      iex> modifier_class_name("large")
      "is-large"
  """
  @spec modifier_class_name(String.t()) :: String.t()
  def modifier_class_name(value) when is_binary(value), do: "is-#{value}"

  for fill <- @fills do
    str = fill |> to_string() |> String.replace("_", "-")
    defp fill_class(unquote(fill)), do: "is-#{unquote(str)}"
  end

  for {w, h} <- @ratios do
    defp ratio_class({unquote(w), unquote(h)}) do
      "is-#{unquote(w)}-by-#{unquote(h)}"
    end
  end

  defp ratio_class(nil), do: nil

  for size <- @sizes do
    str = size |> to_string() |> String.replace("_", "-")
    defp size_class(unquote(size)), do: "is-#{unquote(str)}"
  end

  for shape <- @shapes do
    str = shape |> to_string() |> String.replace("_", "-")
    defp shape_class(unquote(shape)), do: "is-#{unquote(str)}"
  end

  defp shape_class(nil), do: nil

  for type <- @skeleton_types do
    str = type |> to_string() |> String.replace("_", "-")
    defp skeleton_type_class(unquote(type)), do: "is-#{unquote(str)}"
  end

  for variant <- @variants do
    str = variant |> to_string() |> String.replace("_", "-")
    defp variant_class(unquote(variant)), do: "is-#{unquote(str)}"
  end

  defp variant_class(nil), do: nil

  @doc false
  def fills, do: @fills

  @doc false
  def ratios, do: @ratios

  @doc false
  def shapes, do: @shapes

  @doc false
  def sizes, do: @sizes

  @doc false
  def skeleton_types, do: @skeleton_types

  @doc false
  def variants, do: @variants

  @doc false
  def modifier_classes do
    %{
      fills: Enum.map(fills(), &fill_class/1),
      ratios: Enum.map(ratios(), &ratio_class/1),
      shapes: Enum.map(shapes(), &shape_class/1),
      sizes: Enum.map(sizes(), &size_class/1),
      skeleton_types: Enum.map(skeleton_types(), &skeleton_type_class/1),
      variants: Enum.map(variants(), &variant_class/1)
    }
  end

  @doc false
  def ensure_label!(%{label: s, labelledby: nil}, _, _) when is_binary(s) do
    :ok
  end

  def ensure_label!(%{label: nil, labelledby: s}, _, _) when is_binary(s) do
    :ok
  end

  def ensure_label!(_, component, example_label) do
    raise Doggo.InvalidLabelError,
      component: component,
      example_label: example_label
  end
end
