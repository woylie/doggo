defmodule Doggo.Components do
  @moduledoc """
  This module defines macros that generate customized components.

  ## Usage

  Add `use Doggo.Components` to your module and ensure you also add
  `use Phoenix.Component`. Then use the macros in this module to generate the
  components you need.

  > #### `use Doggo.Components` {: .info}
  >
  > When you `use Doggo.Components`, the module will import `Doggo.Components`
  > and define a `__dog_components__/1` function that returns a map containing
  > the options of the Doggo components you used.

  To generate all components with their default options:

      defmodule MyAppWeb.CoreComponents do
        use Doggo.Components
        use Phoenix.Component

        accordion()
        action_bar()
        alert()
        alert_dialog()
        app_bar()
        avatar()
        badge()
        bottom_navigation()
        box()
        breadcrumb()
        button()
        button_link()
        callout()
        card()
        carousel()
        cluster()
        combobox()
        date()
        datetime()
        disclosure_button()
        drawer()
        fab()
        fallback()
        field_group_builder()
        frame_builder()
        icon()
        icon_sprite()
        image()
        menu()
        menu_bar()
        menu_button()
        menu_group()
        menu_item()
        menu_item_checkbox()
        menu_item_radio_group()
        modal()
        navbar()
        navbar_items()
        page_header()
        property_list()
        radio_group()
        skeleton()
        split_pane()
        stack()
        steps()
        switch()
        tab_navigation()
        table()
        tabs()
        tag()
        time()
        toggle_button()
        toolbar()
        tooltip()
        tree()
        tree_item()
        vertical_nav()
        vertical_nav_nested()
        vertical_nav_section()
      end

  ## Common Options

  All component macros support the following options:

  - `name` - The name of the function of the generated component. Defaults to
    the macro name.
  - `base_class` - The base class used on the root element of the component. If
    not set, a default base class is used.
  - `modifiers` - A keyword list of modifier attributes. For each item, an
    attribute with the type `:string` is added. The options will be passed to
    `Phoenix.Component.attr/3`. Most components define a set of default
    modifiers that can be overridden.
  - `class_name_fun` - A 2-arity function that takes a modifier attribute name
    and a value and returns a CSS class name. Defaults to
    `Doggo.modifier_class_name/2`.

  Some components have an `extra` option, which is used to pass additional
  arguments to the component at compile time. This is mostly used to allow
  the customization of certain class names.
  """

  use Phoenix.Component

  import Doggo.Macros

  defmacro __using__(_opts \\ []) do
    quote do
      import Doggo.Components

      Module.register_attribute(__MODULE__, :dog_components, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    components =
      env.module
      |> Module.get_attribute(:dog_components)
      |> Map.new(fn info -> {info[:name], Keyword.delete(info, :name)} end)

    quote do
      def __dog_components__, do: unquote(Macro.escape(components))
    end
  end

  component(
    :accordion,
    modifiers: [],
    doc: """
    Renders a set of headings that control the visibility of their content
    sections.
    """,
    usage: """
    ```heex
    <.accordion id="dog-breeds">
      <:section title="Golden Retriever">
        <p>
          Friendly, intelligent, great with families. Origin: Scotland. Needs
          regular exercise.
        </p>
      </:section>
      <:section title="Siberian Husky">
        <p>
          Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
          Loves cold climates.
        </p>
      </:section>
      <:section title="Dachshund">
        <p>
          Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
        </p>
      </:section>
    </.accordion>
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :expanded, :atom,
          values: [:all, :none, :first],
          default: :all,
          doc: """
          Defines how the accordion sections are initialized.

          - `:all` - All accordion sections are expanded by default.
          - `:none` - All accordion sections are hidden by default.
          - `:first` - Only the first accordion section is expanded by default.
          """

        attr :heading, :string,
          default: "h3",
          values: ["h2", "h3", "h4", "h5", "h6"],
          doc: """
          The heading level for the section title (trigger).
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :section, required: true do
          attr :title, :string
        end
      end,
    heex:
      quote do
        ~H"""
        <div id={@id} class={@class} {@rest}>
          <Doggo.Components.accordion_section
            :for={{section, index} <- Enum.with_index(@section, 1)}
            section={section}
            index={index}
            id={@id}
            expanded={@expanded}
            heading={@heading}
          />
        </div>
        """
      end
  )

  @doc false
  def accordion_section(
        %{
          index: index,
          expanded: expanded_initial
        } = assigns
      ) do
    expanded =
      Doggo.Components.accordion_section_expanded?(index, expanded_initial)

    assigns =
      assign(assigns, aria_expanded: to_string(expanded))

    ~H"""
    <div>
      <.dynamic_tag name={@heading}>
        <button
          id={"#{@id}-trigger-#{@index}"}
          type="button"
          aria-expanded={@aria_expanded}
          aria-controls={"#{@id}-section-#{@index}"}
          phx-click={Doggo.toggle_accordion_section(@id, @index)}
        >
          <span><%= @section.title %></span>
        </button>
      </.dynamic_tag>
      <div
        id={"#{@id}-section-#{@index}"}
        role="region"
        aria-labelledby={"#{@id}-trigger-#{@index}"}
        hidden={@aria_expanded != "true"}
      >
        <%= render_slot(@section) %>
      </div>
    </div>
    """
  end

  @doc false
  def accordion_section_expanded?(_, :all), do: true
  def accordion_section_expanded?(_, :none), do: false
  def accordion_section_expanded?(1, :first), do: true
  def accordion_section_expanded?(_, :first), do: false

  component(
    :action_bar,
    modifiers: [],
    doc: """
    The action bar offers users quick access to primary actions within the
    application.

    It is typically positioned to float above other content.
    """,
    usage: """
    ```heex
    <.action_bar>
      <:item label="Edit" on_click={JS.push("edit")}>
        <.icon><Lucideicons.pencil aria-hidden /></.icon>
      </:item>
      <:item label="Move" on_click={JS.push("move")}>
        <.icon><Lucideicons.move aria-hidden /></.icon>
      </:item>
      <:item label="Archive" on_click={JS.push("archive")}>
        <.icon><Lucideicons.archive aria-hidden /></.icon>
      </:item>
    </.action_bar>
    ```
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Roving tabindex
    - Move focus with arrow keys
    """,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item, required: true do
          attr :label, :string, required: true
          attr :on_click, JS, required: true
        end
      end,
    heex:
      quote do
        ~H"""
        <div role="toolbar" class={@class} {@rest}>
          <button :for={item <- @item} phx-click={item.on_click} title={item.label}>
            <%= render_slot(item) %>
          </button>
        </div>
        """
      end
  )

  component(
    :alert,
    modifiers: [
      level: [
        values: [
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "info"
      ]
    ],
    doc: """
    The alert component serves as a notification mechanism to provide feedback to
    the user.

    For supplementary information that doesn't require the user's immediate
    attention, use `callout/1` instead.
    """,
    usage: """
    Minimal example:

    ```heex
    <.alert id="some-alert"></.alert>
    ```

    With title, icon and level:

    ```heex
    <.alert id="some-alert" level={:info} title="Info">
      message
      <:icon><Heroicon.light_bulb /></:icon>
    </.alert>
    ```
    """,
    type: :feedback,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

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

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block, required: true, doc: "The main content of the alert."
        slot :icon, doc: "Optional slot to render an icon."
      end,
    heex:
      quote do
        ~H"""
        <div
          phx-click={@on_close}
          id={@id}
          role="alert"
          aria-labelledby={@title && "#{@id}-title"}
          class={@class}
          {@rest}
        >
          <div :if={@icon != []} class={"#{@base_class}-icon"}>
            <%= render_slot(@icon) %>
          </div>
          <div class={"#{@base_class}-body"}>
            <div :if={@title} id={"#{@id}-title"} class={"#{@base_class}-title"}>
              <%= @title %>
            </div>
            <div class={"#{@base_class}-message"}><%= render_slot(@inner_block) %></div>
          </div>
          <button :if={@on_close} phx-click={@on_close}>
            <%= @close_label %>
          </button>
        </div>
        """
      end
  )

  component(
    :alert_dialog,
    modifiers: [],
    doc: """
    Renders an alert dialog that requires the immediate attention and response of
    the user.

    This component is meant for situations where critical information must be
    conveyed, and an explicit response is required from the user. It is typically
    used for confirmation dialogs, warning messages, error notifications, and
    other scenarios where an immediate decision is necessary.

    For non-critical dialogs, such as those containing forms or additional
    information, use `Doggo.Components.modal/1` instead.
    """,
    usage: """
    ```heex
    <.alert_dialog id="end-session-modal">
      <:title>End Training Session Early?</:title>
      <p>
        Are you sure you want to end the current training session with Bella?
        She's making great progress today!
      </p>
      <:footer>
        <.button phx-click="end-session">
          Yes, end session
        </.button>
        <.button phx-click={JS.exec("data-cancel", to: "#end-session-modal")}>
          No, continue training
        </.button>
      </:footer>
    </.alert_dialog>
    ```

    To open the dialog, use the `show_modal/1` function.

    ```heex
    <.button
      phx-click={.show_modal("end-session-modal")}
      aria-haspopup="dialog"
    >
      show
    </.button>
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
    """,
    type: :feedback,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :open, :boolean,
          default: false,
          doc: "Initializes the dialog as open."

        attr :on_cancel, Phoenix.LiveView.JS,
          default: %Phoenix.LiveView.JS{},
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

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <dialog
          id={@id}
          role="alertdialog"
          class={@class}
          aria-modal={(@open && "true") || "false"}
          aria-labelledby={"#{@id}-title"}
          aria-describedby={"#{@id}-content"}
          open={@open}
          phx-mounted={@open && Doggo.show_modal(@id)}
          phx-remove={Doggo.hide_modal(@id)}
          data-cancel={Phoenix.LiveView.JS.exec(@on_cancel, "phx-remove")}
          {@rest}
        >
          <.focus_wrap
            id={"#{@id}-container"}
            class={"#{@base_class}-container"}
            phx-window-keydown={
              @dismissable && Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")
            }
            phx-key={@dismissable && "escape"}
            phx-click-away={
              @dismissable && Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")
            }
          >
            <section>
              <header>
                <button
                  :if={@dismissable}
                  href="#"
                  class={"#{@base_class}-close"}
                  aria-label={@close_label}
                  phx-click={Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")}
                >
                  <%= render_slot(@close) %>
                  <span :if={@close == []}>close</span>
                </button>
                <h2 id={"#{@id}-title"}><%= render_slot(@title) %></h2>
              </header>
              <div id={"#{@id}-content"} class={"#{@base_class}-content"}>
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
  )

  component(
    :app_bar,
    modifiers: [],
    doc: """
    The app bar is typically located at the top of the interface and provides
    access to key features and navigation options.
    """,
    usage: """
    ```heex
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
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
        attr :title, :string,
          default: nil,
          doc: "The page title. Will be set as `h1`."

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
      end,
    heex:
      quote do
        ~H"""
        <header class={@class} {@rest}>
          <div :if={@navigation != []} class={"#{@base_class}-navigation"}>
            <.link
              :for={navigation <- @navigation}
              phx-click={navigation.on_click}
              title={navigation.label}
            >
              <%= render_slot(navigation) %>
            </.link>
          </div>
          <h1 :if={@title}><%= @title %></h1>
          <div :if={@action != []} class={"#{@base_class}-actions"}>
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
  )

  component(
    :avatar,
    modifiers: [
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      shape: [values: [nil, "circle"], default: nil]
    ],
    doc: """
    Renders profile picture, typically to represent a user.
    """,
    usage: """
    Minimal example with only the `src` attribute:

    ```heex
    <.avatar src="avatar.png" />
    ```

    Render avatar as a circle:

    ```heex
    <.avatar src="avatar.png" circle />
    ```

    Use a placeholder image in case the avatar is not set:

    ```heex
    <.avatar src={@user.avatar_url} placeholder_src="fallback.png" />
    ```

    Render an text as the placeholder value:

    ```heex
    <.avatar src={@user.avatar_url} placeholder_content="A" />
    ```
    """,
    type: :media,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :src, :any,
          default: nil,
          doc: """
          The URL of the avatar image. If `nil`, the component will use the value
          provided in the placeholder attribute.
          """

        attr :placeholder_src, :any,
          default: nil,
          doc: """
          Fallback image src to use in case the `src` attribute is `nil`.

          If neither `placeholder_src` nor `placeholder_text` are set and the
          `src` is `nil`, no element will be rendered.
          """

        attr :placeholder_content, :any,
          default: nil,
          doc: """
          Fallback content to render in case the `src` attribute is `nil`,
          such as text initials or inline SVG.

          If `placeholder_src` is set, this attribute is ignored.

          If neither `placeholder_src` nor `placeholder_text` are set and the
          `src` is `nil`, no element will be rendered.
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

        attr :loading, :string, values: ["eager", "lazy"], default: "lazy"
        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <div
          :if={@src || @placeholder_src || @placeholder_content}
          class={@class}
          {@rest}
        >
          <Doggo.Components.inner_avatar
            src={@src}
            placeholder_src={@placeholder_src}
            placeholder_content={@placeholder_content}
            alt={@alt}
            loading={@loading}
          />
        </div>
        """
      end
  )

  @doc false
  def inner_avatar(%{src: src} = assigns) when is_binary(src) do
    ~H"""
    <img src={@src} alt={@alt} loading={@loading} />
    """
  end

  def inner_avatar(%{placeholder_src: src} = assigns) when is_binary(src) do
    ~H"""
    <img src={@placeholder_src} alt={@alt} loading={@loading} />
    """
  end

  def inner_avatar(assigns) do
    ~H"""
    <span><%= @placeholder_content %></span>
    """
  end

  component(
    :badge,
    modifiers: [
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      variant: [
        values: [
          nil,
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: nil
      ]
    ],
    doc: """
    Generates a badge component, typically used for drawing attention to elements
    like notification counts.
    """,
    usage: """
    ```heex
    <.badge>8</.badge>
    ```
    """,
    type: :feedback,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <span class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </span>
        """
      end
  )

  component(
    :bottom_navigation,
    modifiers: [],
    doc: """
    Renders a navigation that sticks to the bottom of the screen.
    """,
    usage: """
    ```heex
    <.bottom_navigation current_value={@view}>
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
    </.bottom_navigation>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
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
      end,
    heex:
      quote do
        ~H"""
        <nav aria-label={@label} class={@class} {@rest}>
          <ul>
            <li :for={item <- @item}>
              <.link
                href={item[:href]}
                navigate={item[:navigate]}
                patch={item[:patch]}
                aria-current={@current_value in List.wrap(item.value) && "page"}
                aria-label={item.label}
              >
                <span class={"#{@base_class}-icon"}><%= render_slot(item) %></span>
                <span :if={!@hide_labels}><%= item.label %></span>
              </.link>
            </li>
          </ul>
        </nav>
        """
      end
  )

  component(
    :box,
    modifiers: [],
    doc: """
    Renders a box for a section on the page.
    """,
    usage: """
    Minimal example with only a box body:

    ```heex
    <.box>
      <p>This is a box.</p>
    </.box>
    ```

    With title, banner, action, and footer:

    ```heex
    <box>
      <:title>Profile</:title>
      <:banner>
        <img src="banner-image.png" alt="" />
      </:banner>
      <:action>
        <button_link patch={~p"/profiles/\#{@profile}/edit"}>Edit</button_link>
      </:action>

      <p>This is a profile.</p>

      <:footer>
        <p>Last edited: <%= @profile.updated_at %></p>
      </:footer>
    </box>
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        slot :title, doc: "The title for the box."

        slot :inner_block,
          required: true,
          doc: "Slot for the content of the box body."

        slot :action, doc: "A slot for action buttons related to the box."

        slot :banner,
          doc: "A slot that can be used to render a banner image in the header."

        slot :footer, doc: "An optional slot for the footer."

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <section class={@class} {@rest}>
          <header :if={@title != [] || @banner != [] || @action != []}>
            <h2 :if={@title != []}><%= render_slot(@title) %></h2>
            <div :if={@action != []} class={"#{@base_class}-actions"}>
              <%= for action <- @action do %>
                <%= render_slot(action) %>
              <% end %>
            </div>
            <div :if={@banner != []} class={"#{@base_class}-banner"}>
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
  )

  component(
    :breadcrumb,
    modifiers: [],
    doc: """
    Renders a breadcrumb navigation.
    """,
    usage: """
    ```heex
    <.breadcrumb>
      <:item patch="/categories">Categories</:item>
      <:item patch="/categories/1">Reviews</:item>
      <:item patch="/categories/1/articles/1">The Movie</:item>
    </.breadcrumb>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: "Breadcrumb",
          doc: """
          The aria label for the `<nav>` element.

          The label should start with a capital letter, be localized, and should
          not repeat the word 'navigation'.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item, required: true do
          attr :navigate, :string
          attr :patch, :string
          attr :href, :string
        end
      end,
    heex:
      quote do
        [last_item | rest] = Enum.reverse(var!(assigns).item)

        var!(assigns) =
          assign(
            var!(assigns),
            :item,
            Enum.reverse([{:current, last_item} | rest])
          )

        ~H"""
        <nav aria-label={@label} class={@class} {@rest}>
          <ol>
            <li :for={item <- @item}>
              <Doggo.Components.breadcrumb_link item={item} />
            </li>
          </ol>
        </nav>
        """
      end
  )

  @doc false
  def breadcrumb_link(%{item: {:current, current_item}} = assigns) do
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

  def breadcrumb_link(assigns) do
    ~H"""
    <.link navigate={@item[:navigate]} patch={@item[:patch]} href={@item[:href]}>
      <%= render_slot(@item) %>
    </.link>
    """
  end

  component(
    :button,
    modifiers: [
      variant: [
        values: [
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "primary"
      ],
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      fill: [values: ["solid", "outline", "text"], default: "solid"],
      shape: [values: [nil, "circle", "pill"], default: nil]
    ],
    doc: """
    Renders a button.

    Use this component when you need to perform an action that doesn't involve
    navigating to a different page, such as submitting a form, confirming an
    action, or deleting an item.

    If you need to navigate to a different page or a specific section on the
    current page and want to style the link like a button, use `button_link/1`
    instead.

    See also `button_link/1`, `toggle_button/1`, and `disclosure_button/1`.
    """,
    usage: """
    ```heex
    <.button>Confirm</.button>

    <.button type="submit">
      Submit
    </.button>
    ```

    To indicate a loading state, for example when submitting a form, use the
    `aria-busy` attribute:

    ```heex
    <.button aria-label="Saving..." aria-busy>
      click me
    </.button>
    ```
    """,
    type: :buttons,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :type, :string,
          values: ["button", "reset", "submit"],
          default: "button"

        attr :disabled, :boolean, default: nil
        attr :rest, :global, include: ~w(autofocus form name value)

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <button type={@type} class={@class} disabled={@disabled} {@rest}>
          <%= render_slot(@inner_block) %>
        </button>
        """
      end
  )

  component(
    :button_link,
    base_class: "button",
    extra: [disabled_class: "is-disabled"],
    modifiers: [
      variant: [
        values: [
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "primary"
      ],
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      fill: [values: ["solid", "outline", "text"], default: "solid"],
      shape: [values: [nil, "circle", "pill"], default: nil]
    ],
    doc: """
    Renders a link (`<a>`) that has the role and style of a button.

    Use this component when you need to style a link to a different page or a
    specific section within the same page as a button.

    To perform an action on the same page, including toggles and revealing/hiding
    elements, you should always use a real button instead. See `button/1`,
    `toggle_button/1`, and `disclosure_button/1`.
    """,
    usage: """
    ```heex
    <.button_link patch={~p"/confirm"}>
      Confirm
    </.button_link>

    <.button_link navigate={~p"/registration"}>
      Registration
    </.button_link>
    ```
    """,
    type: :buttons,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :disabled, :boolean,
          default: false,
          doc: """
          Since `<a>` tags cannot have a `disabled` attribute, this attribute
          toggles a class.
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
      end,
    heex: fn extra ->
      disabled_class = Keyword.fetch!(extra, :disabled_class)

      quote do
        var!(assigns) =
          if var!(assigns)[:disabled] do
            Map.update!(
              var!(assigns),
              :class,
              &(&1 ++ [unquote(disabled_class)])
            )
          else
            var!(assigns)
          end

        ~H"""
        <.link class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </.link>
        """
      end
    end
  )

  component(
    :callout,
    modifiers: [
      variant: [
        values: [
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "info"
      ]
    ],
    doc: """
    Use the callout to highlight supplementary information related to the main
    content.

    For information that needs immediate attention of the user, use `alert/1`
    instead.
    """,
    usage: """
    Standard callout:

    ```heex
    <.callout title="Dog Care Tip">
      <p>Regular exercise is essential for keeping your dog healthy and happy.</p>
    </.callout>
    ```

    Callout with an icon:

    ```heex
    <.callout title="Fun Dog Fact">
      <:icon><Heroicons.information_circle /></:icon>
      <p>
        Did you know? Dogs have a sense of time and can get upset when their
        routine is changed.
      </p>
    </.callout>
    ```
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true
        attr :title, :string, default: nil, doc: "An optional title."
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block, required: true, doc: "The main content of the alert."
        slot :icon, doc: "Optional slot to render an icon."
      end,
    heex:
      quote do
        ~H"""
        <aside
          id={@id}
          class={@class}
          aria-labelledby={@title && "#{@id}-title"}
          {@rest}
        >
          <div :if={@icon != []} class={"#{@base_class}-icon"}>
            <%= render_slot(@icon) %>
          </div>
          <div class={"#{@base_class}-body"}>
            <div :if={@title} id={"#{@id}-title"} class={"#{@base_class}-title"}>
              <%= @title %>
            </div>
            <div class={"#{@base_class}-message"}>
              <%= render_slot(@inner_block) %>
            </div>
          </div>
        </aside>
        """
      end
  )

  component(
    :card,
    modifiers: [],
    doc: """
    Renders a card in an `article` tag, typically used repetitively in a grid or
    flex box layout.
    """,
    usage: """
    ```heex
    <.card>
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
    </.card>
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
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
      end,
    heex:
      quote do
        ~H"""
        <article class={@class} {@rest}>
          <figure :if={@image != []}><%= render_slot(@image) %></figure>
          <header :if={@header != []}><%= render_slot(@header) %></header>
          <main :if={@main != []}><%= render_slot(@main) %></main>
          <footer :if={@footer != []}><%= render_slot(@footer) %></footer>
        </article>
        """
      end
  )

  component(
    :carousel,
    modifiers: [],
    doc: """
    Renders a carousel for presenting a sequence of items, such as images or text.
    """,
    usage: """
    ```heex
    <.carousel label="Our Dogs">
      <:previous label="Previous Slide">
        <Heroicons.chevron_left />
      </:previous>
      <:next label="Next Slide">
        <Heroicons.chevron_right />
      </:next>
      <:item label="1 of 3">
        <.image
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog wearing a colorful poncho walks down a fashion show runway."
          ratio={{16, 9}}
        />
      </:item>
      <:item label="2 of 3">
        <.image
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog dressed in a sumptuous, baroque-style costume, complete with jewels and intricate embroidery, parades on an ornate runway at a luxurious fashion show, embodying opulence and grandeur."
          ratio={{16, 9}}
        />
      </:item>
      <:item label="3 of 3">
        <.image
          src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
          alt="A dog adorned in a lavish, flamboyant outfit, including a large feathered hat and elaborate jewelry, struts confidently down a luxurious fashion show runway, surrounded by bright lights and an enthusiastic audience."
          ratio={{16, 9}}
        />
      </:item>
    </.carousel>
    ```
    """,
    type: :media,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Handle previous/next buttons
    - Handle pagination tabs
    - Auto rotation
    - Disable auto rotation when controls are used
    - Disable previous/next button on first/last item.
    - Focus management and keyboard support for pagination
    """,
    attrs_and_slots:
      quote do
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
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".carousel", "Our Dogs")

        ~H"""
        <section
          id={@id}
          class={@class}
          aria-label={@label}
          aria-labelledby={@labelledby}
          aria-roledescription={@carousel_roledescription}
          {@rest}
        >
          <div class={"#{@base_class}-inner"}>
            <div class={"#{@base_class}-controls"}>
              <button
                :for={previous <- @previous}
                type="button"
                class={"#{@base_class}-previous"}
                aria-controls={"#{@id}-items"}
                aria-label={previous.label}
              >
                <%= render_slot(previous) %>
              </button>
              <button
                :for={next <- @next}
                type="button"
                class={"#{@base_class}-next"}
                aria-controls={"#{@id}-items"}
                aria-label={next.label}
              >
                <%= render_slot(next) %>
              </button>
              <div :if={@pagination} class={"#{@base_class}-pagination"}>
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
              class={"#{@base_class}-items"}
              aria-live={if @auto_rotation, do: "off", else: "polite"}
            >
              <div
                :for={{item, index} <- Enum.with_index(@item, 1)}
                id={"#{@id}-item-#{index}"}
                class={"#{@base_class}-item"}
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
  )

  component(
    :cluster,
    modifiers: [],
    doc: """
    Use the cluster component to visually group children.

    Common use cases are groups of buttons, or group of tags.
    """,
    usage: """
    ```heex
    <.cluster>
      <div>some item</div>
      <div>some other item</div>
    </.cluster>
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :refining,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <div class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </div>
        """
      end
  )

  component(
    :combobox,
    modifiers: [],
    doc: """
    Renders a text input with a popup that allows users to select a value from
    a list of suggestions.
    """,
    usage: """
    With simple values:

    ```heex
    <.combobox
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
    <.combobox
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
    <.combobox
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
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Showing/hiding suggestions
    - Filtering suggestions
    - Selecting a value
    - Focus management
    - Keyboard support
    """,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true, doc: "Sets the DOM ID for the input."

        attr :name, :string,
          required: true,
          doc: "Sets the name for the text input."

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
      end,
    heex:
      quote do
        %{name: name, options: options, value: value} = var!(assigns)

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

        var!(assigns) =
          assign(var!(assigns),
            search_name: search_name,
            search_value: search_value
          )

        ~H"""
        <div class={@class} {@rest}>
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
            <Doggo.Components.combobox_option
              :for={option <- @options}
              base_class={@base_class}
              option={option}
            />
          </ul>
          <input type="hidden" id={"#{@id}-value"} name={@name} value={@value} />
        </div>
        """
      end
  )

  @doc false
  def combobox_option(%{option: {label, value}} = assigns) do
    assigns = assign(assigns, label: label, value: value, option: nil)

    ~H"""
    <li role="option" data-value={@value}>
      <span class={"#{@base_class}-option-label"}><%= @label %></span>
    </li>
    """
  end

  def combobox_option(%{option: {label, value, description}} = assigns) do
    assigns =
      assign(assigns,
        label: label,
        value: value,
        description: description,
        option: nil
      )

    ~H"""
    <li role="option" data-value={@value}>
      <span class={"#{@base_class}-option-label"}><%= @label %></span>
      <span class={"#{@base_class}-option-description"}><%= @description %></span>
    </li>
    """
  end

  def combobox_option(assigns) do
    ~H"""
    <li role="option" data-value={@option}>
      <span class={"#{@base_class}-option-label"}><%= @option %></span>
    </li>
    """
  end

  component(
    :date,
    base_class: nil,
    modifiers: [],
    doc: """
    Renders a `Date`, `DateTime`, or `NaiveDateTime` in a `<time>` tag.
    """,
    usage: """
    By default, the given value is formatted for display with `to_string/1`. This:

    ```heex
    <.date value={~D[2023-02-05]} />
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
    <.date
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
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :value, :any,
          required: true,
          doc: """
          Either a `Date`, `DateTime`, or `NaiveDateTime`.
          """

        attr :formatter, :any,
          default: nil,
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

        attr :rest, :global, include: ~w(autofocus form name value)
      end,
    heex:
      quote do
        %{
          value: value,
          timezone: timezone,
          formatter: formatter,
          title_formatter: title_formatter
        } = var!(assigns)

        formatter = formatter || (&to_string/1)

        value =
          value
          |> Doggo.shift_zone(timezone)
          |> Doggo.to_date()

        var!(assigns) =
          assigns
          |> var!()
          |> assign(:datetime, value && Date.to_iso8601(value))
          |> assign(
            :title,
            value && Doggo.time_title_attr(value, title_formatter)
          )
          |> assign(:value, value && formatter.(value))

        ~H"""
        <time :if={@value} class={@class} datetime={@datetime} title={@title} {@rest}>
          <%= @value %>
        </time>
        """
      end
  )

  component(
    :datetime,
    base_class: nil,
    modifiers: [],
    doc: """
    Renders a `DateTime` or `NaiveDateTime` in a `<time>` tag.
    """,
    usage: """
    By default, the given value is formatted for display with `to_string/1`. This:

    ```heex
    <.datetime value={~U[2023-02-05 12:22:06.003Z]} />
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
    <.datetime
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
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :value, :any,
          required: true,
          doc: """
          Either a `DateTime` or `NaiveDateTime`.
          """

        attr :formatter, :any,
          default: nil,
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

        attr :rest, :global
      end,
    heex:
      quote do
        %{
          value: value,
          precision: precision,
          timezone: timezone,
          formatter: formatter,
          title_formatter: title_formatter
        } = var!(assigns)

        formatter = formatter || (&to_string/1)

        value =
          value
          |> Doggo.shift_zone(timezone)
          |> Doggo.truncate_datetime(precision)

        var!(assigns) =
          assigns
          |> var!()
          |> assign(:datetime, value && Doggo.datetime_attr(value))
          |> assign(
            :title,
            value && Doggo.time_title_attr(value, title_formatter)
          )
          |> assign(:value, value && formatter.(value))

        ~H"""
        <time :if={@value} class={@class} datetime={@datetime} title={@title} {@rest}>
          <%= @value %>
        </time>
        """
      end
  )

  component(
    :disclosure_button,
    base_class: "button",
    modifiers: [
      variant: [
        values: [
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "primary"
      ],
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      fill: [values: ["solid", "outline", "text"], default: "solid"],
      shape: [values: [nil, "circle", "pill"], default: nil]
    ],
    doc: """
    Renders a button that toggles the visibility of another element.

    Use this component to reveal or hide additional content, such as in
    collapsible sections or dropdown menus.

    For a button that toggles other states, use `toggle_button/1` instead. See
    also `button/1` and `button_link/1`.
    """,
    usage: """
    Set the `controls` attribute to the DOM ID of the element that you want to
    toggle with the button.

    The initial state is hidden. Do not forget to add the `hidden` attribute to
    the toggled element. Otherwise, visibility of the element will not align with
    the `aria-expanded` attribute of the button.

    ```heex
    <.disclosure_button controls="data-table">
      Data Table
    </.disclosure_button>

    <table id="data-table" hidden></table>
    ```
    """,
    type: :buttons,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :controls, :string,
          required: true,
          doc: """
          The DOM ID of the element that this button controls.
          """

        attr :rest, :global, include: ~w(autofocus form name value)

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <button
          type="button"
          aria-expanded="false"
          aria-controls={@controls}
          phx-click={Doggo.toggle_disclosure(@controls)}
          class={@class}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
        """
      end
  )

  component(
    :drawer,
    modifiers: [],
    doc: """
    Renders a drawer with a `brand`, `top`, and `bottom` slot.

    All slots are optional, and you can render any content in them. If you want
    to use the drawer as a sidebar, you can use the `vertical_nav/1` and
    `vertical_nav_section/1` components.
    """,
    usage: """
    Minimal example:

    ```heex
    <.drawer>
      <:main>Content</:main>
    </.drawer>
    ```

    With all slots:

    ```heex
    <.drawer>
      <:header>Doggo</:header>
      <:main>Content at the top</:main>
      <:footer>Content at the bottom</:footer>
    </.drawer>
    ```

    With navigation and sections:

    ```heex
    <.drawer>
      <:header>
        <.link navigate={~p"/"}>App</.link>
      </:header>
      <:main>
        <.vertical_nav label="Main">
          <:item>
            <.link navigate={~p"/dashboard"}>Dashboard</.link>
          </:item>
          <:item>
            <.vertical_nav_nested>
              <:title>Content</:title>
              <:item current_page>
                <.link navigate={~p"/posts"}>Posts</.link>
              </:item>
              <:item>
                <.link navigate={~p"/comments"}>Comments</.link>
              </:item>
            </.vertical_nav_nested>
          </:item>
        </.vertical_nav>
        <.vertical_nav_section>
          <:title>Search</:title>
          <:item><input type="search" placeholder="Search" /></:item>
        </.vertical_nav_section>
      </:main>
      <:footer>
        <.vertical_nav label="User menu">
          <:item>
            <.link navigate={~p"/settings"}>Settings</.link>
          </:item>
          <:item>
            <.link navigate={~p"/logout"}>Logout</.link>
          </:item>
        </.vertical_nav>
      </:footer>
    </.drawer>
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
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
      end,
    heex:
      quote do
        ~H"""
        <aside class={@class} {@rest}>
          <div :if={@header != []} class={"#{@base_class}-header"}>
            <%= render_slot(@header) %>
          </div>
          <div :if={@main != []} class={"#{@base_class}-main"}>
            <%= render_slot(@main) %>
          </div>
          <div :if={@footer != []} class={"#{@base_class}-footer"}>
            <%= render_slot(@footer) %>
          </div>
        </aside>
        """
      end
  )

  component(
    :fab,
    modifiers: [
      variant: [
        values: [
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "primary"
      ],
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      shape: [values: [nil, "circle", "pill"], default: "circle"]
    ],
    doc: """
    Renders a floating action button.
    """,
    usage: """
    ```heex
    <.fab label="Add item" phx-click={JS.patch(to: "/items/new")}>
      <.icon><Heroicons.plus /></.icon>
    </.fab>
    ```
    """,
    type: :buttons,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :label, :string, required: true
        attr :disabled, :boolean, default: false
        attr :rest, :global, include: ~w(autofocus form name value)

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <button
          type="button"
          aria-label={@label}
          class={@class}
          disabled={@disabled}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
        """
      end
  )

  component(
    :fallback,
    modifiers: [],
    doc: """
    The fallback component renders a given value unless it is empty, in which case
    it renders a fallback value instead.

    The values `nil`, `""`, `[]` and `%{}` are treated as empty values.

    This component optionally applies a formatter function to non-empty values.

    The primary purpose of this component is to enhance accessibility. In
    situations where a value in a table column or property list is set to be
    invisible or not displayed, it's crucial to provide an alternative text for
    screen readers.
    """,
    usage: """
    Render the value of `@some_value` if it's available, or display the
    default placeholder otherwise:

    ```heex
    <.fallback value={@some_value} />
    ```

    Apply a formatter function to `@some_value` if it is not `nil`:

    ```heex
    <.fallback value={@some_value} formatter={&format_date/1} />
    ```

    Set a custom placeholder and text for screen readers:

    ```heex
    <.fallback
      value={@some_value}
      placeholder="n/a"
      accessibility_text="not available"
    />
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
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

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        %{value: value, formatter: formatter} = var!(assigns)

        value =
          cond do
            value in [nil, "", [], %{}] -> nil
            is_nil(formatter) -> value
            true -> formatter.(value)
          end

        var!(assigns) = assign(var!(assigns), :value, value)

        ~H"""
        <%= @value %><span
          :if={is_nil(@value)}
          class={@class}
          aria-label={@accessibility_text}
          {@rest}
        ><%= @placeholder %></span>
        """
      end
  )

  component(
    :field_group_builder,
    name: :field_group,
    base_class: "field-group",
    modifiers: [],
    doc: """
    Use the field group component to visually group multiple inputs in a form.

    This component is intended for styling purposes and does not provide semantic
    grouping. For semantic grouping of related form elements, use the `<fieldset>`
    and `<legend>` HTML elements instead.
    """,
    usage: """
    Visual grouping of inputs:

    ```heex
    <.field_group>
      <.input field={@form[:given_name]} label="Given name" />
      <.input field={@form[:family_name]} label="Family name"/>
    </.field_group>
    ```

    Semantic grouping (for reference):

    ```heex
    <fieldset>
      <legend>Personal Information</legend>
      <.input field={@form[:given_name]} label="Given name" />
      <.input field={@form[:family_name]} label="Family name"/>
    </fieldset>
    ```
    """,
    type: :form,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <div class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </div>
        """
      end
  )

  component(
    :frame_builder,
    name: :frame,
    base_class: "frame",
    modifiers: [
      ratio: [
        values: [
          nil,
          "1-by-1",
          "3-by-2",
          "2-by-3",
          "4-by-3",
          "3-by-4",
          "5-by-4",
          "4-by-5",
          "16-by-9",
          "9-by-16"
        ],
        default: nil
      ],
      shape: [values: [nil, "circle"], default: nil]
    ],
    doc: """
    Renders a frame with an aspect ratio for images or videos.

    This component is used within the `image/1` component.
    """,
    usage: """
    Rendering an image with the aspect ratio 4:3.

    ```heex
    <.frame ratio={{4, 3}}>
      <img src="image.png" alt="An example image illustrating the usage." />
    </.frame>
    ```

    Rendering an image as a circle.

    ```heex
    <.frame circle>
      <img src="image.png" alt="An example image illustrating the usage." />
    </.frame>
    ```
    """,
    type: :media,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block
      end,
    heex:
      quote do
        ~H"""
        <div class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </div>
        """
      end
  )

  component(
    :icon,
    modifiers: [
      size: [values: ["small", "normal", "medium", "large"], default: "normal"]
    ],
    extra: [
      visually_hidden_class: "is-visually-hidden"
    ],
    doc: """
    Renders a customizable icon using a slot for SVG content.

    This component does not bind you to a specific set of icons. Instead, it
    provides a slot for inserting SVG content from any icon library you choose.
    """,
    usage: """
    Render an icon with text as `aria-label` using the `heroicons` library:

    ```heex
    <.icon label="report bug"><Heroicons.bug_ant /></.icon>
    ```

    To display the text visibly:

    ```heex
    <.icon label="report bug" label_placement={:right}>
      <Heroicons.bug_ant />
    </.icon>
    ```

    > #### aria-hidden {: .info}
    >
    > Not all icon libraries set the `aria-hidden` attribute by default. Always
    > make sure that it is set on the `<svg>` element that the library renders.
    """,
    type: :media,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
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

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex: fn extra ->
      visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)

      quote do
        var!(assigns) =
          assigns
          |> var!()
          |> Map.update!(
            :class,
            &(&1 ++
                [Doggo.label_placement_class(var!(assigns).label_placement)])
          )
          |> assign(:visually_hidden_class, unquote(visually_hidden_class))

        ~H"""
        <span class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
          <span
            :if={@label}
            class={@label_placement == :hidden && @visually_hidden_class}
          >
            <%= @label %>
          </span>
        </span>
        """
      end
    end
  )

  component(
    :icon_sprite,
    base_class: "icon",
    maturity: :developing,
    modifiers: [
      size: [values: ["small", "normal", "medium", "large"], default: "normal"]
    ],
    extra: [
      visually_hidden_class: "is-visually-hidden"
    ],
    doc: """
    Renders an icon using an SVG sprite.
    """,
    usage: """
    Render an icon with text as `aria-label`:

    ```heex
    <.icon name="arrow-left" label="Go back" />
    ```

    To display the text visibly:

    ```heex
    <.icon name="arrow-left" label="Go back" label_placement={:right} />
    ```
    """,
    type: :media,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :name, :string,
          required: true,
          doc: "Icon name as used in the sprite."

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

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex: fn extra ->
      visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)

      quote do
        var!(assigns) =
          assigns
          |> var!()
          |> Map.update!(
            :class,
            &(&1 ++
                [Doggo.label_placement_class(var!(assigns).label_placement)])
          )
          |> assign(:visually_hidden_class, unquote(visually_hidden_class))

        ~H"""
        <span class={@class} {@rest}>
          <svg aria-hidden="true"><use href={"#{@sprite_url}##{@name}"} /></svg>
          <span
            :if={@label}
            class={@label_placement == :hidden && @visually_hidden_class}
          >
            <%= @label %>
          </span>
        </span>
        """
      end
    end
  )

  component(
    :image,
    modifiers: [
      ratio: [
        values: [
          nil,
          "1-by-1",
          "3-by-2",
          "2-by-3",
          "4-by-3",
          "3-by-4",
          "5-by-4",
          "4-by-5",
          "16-by-9",
          "9-by-16"
        ],
        default: nil
      ]
    ],
    doc: """
    Renders an image with an optional caption.

    Note that this component relies on the frame component being compiled in the
    same module with `frame_builder/1` with the default name (`:frame`). If you
    override the default ratios, ensure that both the `image` component and
    the `frame` component are generated with the same values.
    """,
    usage: """
    ```heex
    <.image
      src="https://github.com/woylie/doggo/blob/main/assets/dog_poncho.jpg?raw=true"
      alt="A dog wearing a colorful poncho walks down a fashion show runway."
      ratio={{16, 9}}
    >
      <:caption>
        Spotlight on canine couture: A dog fashion show where four-legged models
        dazzle the runway with the latest in pet apparel.
      </:caption>
    </.image>
    ```
    """,
    type: :media,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :src, :string,
          required: true,
          doc: "The URL of the image to render."

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
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :caption
      end,
    heex:
      quote do
        ~H"""
        <figure class={@class} {@rest}>
          <.frame ratio={@ratio}>
            <img
              src={@src}
              width={@width}
              height={@height}
              alt={@alt}
              loading={@loading}
              srcset={Doggo.build_srcset(@srcset)}
              sizes={@sizes}
            />
          </.frame>
          <figcaption :if={@caption != []}><%= render_slot(@caption) %></figcaption>
        </figure>
        """
      end
  )

  component(
    :menu,
    modifiers: [],
    doc: """
    Renders a menu that offers a list of actions or functions.

    This component is meant for organizing actions within an application, rather
    than for navigating between different pages or sections of a website.

    See also `menu_bar/1`, `menu_group/1`, `menu_button/1`, `menu_item/1`, and
    `menu_item_checkbox/1`.
    """,
    usage: """
    If the menu is always visible or can only be toggled by a keyboard shortcut,
    set the `label` attribute.

    ```heex
    <.menu label="Actions">
      <:item>Copy</:item>
      <:item>Paste</:item>
      <:item role="separator"></:item>
      <:item>Sort lines</:item>
    </.menu>
    ```

    If the menu is toggled by a `menu_button/1`, ensure that the `controls`
    attribute of the button matches the DOM ID of the menu and that the
    `labelledby` attribute of the menu matches the DOM ID of the button.

    <.menu_button controls="actions-menu" id="actions-button">
      Actions
    </.menu_button>
    <.menu labelledby="actions-button" hidden></.menu>
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Focus management
    - keyboard support
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: nil,
          doc: """
          A accessibility label for the menubar. Set as `aria-label` attribute.

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          The DOM ID of an element that labels this menubar. If the menu is toggled
          by a `menu_button/1`, this attribute should be set to the DOM ID of that
          button.

          Example:

          ```html
          <Doggo.menu_button controls="actions-menu" id="actions-button">
            Actions
          </Doggo.menu_button>
          <Doggo.menu labelledby="actions-button" hidden></Doggo.menu>
          ```

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item, required: true do
          attr :role, :string,
            values: ["none", "separator"],
            doc: """
            Sets the role of the list item. If the item has a menu item, group, menu
            item radio group or menu item checkbox as a child, use `"none"`. If you
            want to render a visual separator, use `"separator"`. The default is
            `"none"`.
            """
        end
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".menu", "Dog Actions")

        ~H"""
        <ul
          class={@class}
          role="menu"
          aria-label={@label}
          aria-labelledby={@labelledby}
          {@rest}
        >
          <li :for={item <- @item} role={item[:role] || "none"}>
            <%= if item[:role] != "separator" do %>
              <%= render_slot(item) %>
            <% end %>
          </li>
        </ul>
        """
      end
  )

  component(
    :menu_bar,
    modifiers: [],
    doc: """
    Renders a menu bar, similar to those found in desktop applications.

    This component is meant for organizing actions within an application, rather
    than for navigating between different pages or sections of a website.

    See also `menu/1`, `menu_group/1`, `menu_button/1`, `menu_item/1`, and
    `menu_item_checkbox/1`.
    """,
    usage: """
    ```heex
    <.menu_bar label="Main">
      <:item>
        <.menu_button controls="actions-menu" id="actions-button">
          Actions
        </.menu_button>

        <.menu id="actions-menu" labelledby="actions-button" hidden>
          <:item>
            <.menu_item on_click={JS.push("view-dog-profiles")}>
              View Dog Profiles
            </.menu_item>
          </:item>
          <:item>
            <.menu_item on_click={JS.push("add-dog-profile")}>
              Add Dog Profile
            </.menu_item>
          </:item>
          <:item>
            <.menu_item on_click={JS.push("dog-care-tips")}>
              Dog Care Tips
            </.menu_item>
          </:item>
        </.menu>
      </:item>
      <:item role="separator"></:item>
      <:item>
        <.menu_item on_click={JS.dispatch("myapp:help")}>
          Help
        </.menu_item>
      </:item>
    </.menu_bar>
    ```
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Focus management
    - keyboard support
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: nil,
          doc: """
          A accessibility label for the menubar. Set as `aria-label` attribute.

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          The DOM ID of an element that labels this menu bar.

          Example:

          ```html
          <h3 id="dog-menu-label">Dog Actions</h3>
          <Doggo.menu_bar labelledby="dog-menu-label"></Doggo.menu_bar>
          ```

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item, required: true do
          attr :role, :string,
            values: ["none", "separator"],
            doc: """
            Sets the role of the list item. If the item has a menu item, group, menu
            item radio group or menu item checkbox as a child, use `"none"`. If you
            want to render a visual separator, use `"separator"`. The default is
            `"none"`.
            """
        end
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".menu_bar", "Dog Actions")

        ~H"""
        <ul
          class={@class}
          role="menubar"
          aria-label={@label}
          aria-labelledby={@labelledby}
          {@rest}
        >
          <li :for={item <- @item} role={item[:role] || "none"}>
            <%= if item[:role] != "separator" do %>
              <%= render_slot(item) %>
            <% end %>
          </li>
        </ul>
        """
      end
  )

  component(
    :menu_button,
    modifiers: [],
    doc: """
    Renders a button that toggles an actions menu.

    This component can be used on its own or as part of a `menu_bar/1` or `menu/1`.
    See also `menu_item/1`, `menu_item_checkbox/1`, and `menu_group/1`.

    For a button that toggles the visibility of an element that is not a menu, use
    `disclosure_button/1`. For a button that toggles other states, use
    `toggle_button/1`. See also `button/1` and `button_link/1`.
    """,
    usage: """
    Set the `controls` attribute to the DOM ID of the element that you want to
    toggle with the button.

    The initial state is hidden. Do not forget to add the `hidden` attribute to
    the toggled menu. Otherwise, visibility of the element will not align with
    the `aria-expanded` attribute of the button.

    ```heex
    <div>
      <.menu_button controls="actions-menu" id="actions-button">
        Actions
      </.menu_button>

      <.menu id="actions-menu" labelledby="actions-button" hidden>
        <:item>
          <.menu_item on_click={JS.push("view-dog-profiles")}>
            View Dog Profiles
          </.menu_item>
        </:item>
        <:item>
          <.menu_item on_click={JS.push("add-dog-profile")}>
            Add Dog Profile
          </.menu_item>
        </:item>
        <:item>
          <.menu_item on_click={JS.push("dog-care-tips")}>
            Dog Care Tips
          </.menu_item>
        </:item>
      </.menu>
    </div>
    ```

    If this menu button is a child of a `menu_bar/1` or a `menu/1`, set the
    `menuitem` attribute.

    ```heex
    <.menu id="actions-menu">
      <:item>
        <.menu_button controls="actions-menu" id="actions-button" menuitem>
          Dog Actions
        </.menu_button>
        <.menu id="dog-actions-menu" labelledby="actions-button" hidden>
          <:item><!-- ... --></:item>
        </.menu>
      </:item>
      <:item><!-- ... --></:item>
    </.menu>
    ```
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
        attr :id, :string,
          required: true,
          doc: """
          The DOM ID of the button. Set the `aria-labelledby` attribute of the toggled
          menu to the same value.
          """

        attr :controls, :string,
          required: true,
          doc: """
          The DOM ID of the element that this button controls.
          """

        attr :menuitem, :boolean,
          default: false,
          doc: """
          Set this attribute to `true` if the menu button is used as a child of a
          `menu_bar/1`. This ensures that the `role` is set to `menuitem`.
          """

        attr :rest, :global

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <button
          class={@class}
          id={@id}
          type="button"
          role={@menuitem && "menuitem"}
          aria-haspopup="true"
          aria-expanded="false"
          aria-controls={@controls}
          phx-click={Doggo.toggle_disclosure(@controls)}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
        """
      end
  )

  component(
    :menu_group,
    modifiers: [],
    doc: """
    This component can be used to group items within a `menu/1` or `menu_bar/1`.

    See also `menu_button/1`, `menu_item/1`, and `menu_item_checkbox/1`.
    """,
    usage: """
    ```heex
    <.menu id="actions-menu" labelledby="actions-button" hidden>
      <:item>
        <.menu_group label="Dog actions">
          <:item>
            <.menu_item on_click={JS.push("view-dog-profiles")}>
              View Dog Profiles
            </.menu_item>
          </:item>
          <:item>
            <.menu_item on_click={JS.push("add-dog-profile")}>
              Add Dog Profile
            </.menu_item>
          </:item>
          <:item>
            <.menu_item on_click={JS.push("dog-care-tips")}>
              Dog Care Tips
            </.menu_item>
          </:item>
        </.menu_group>
      </:item>
      <:item role="separator" />
      <:item>
        <.menu_item on_click={JS.push("help")}>Help</.menu_item>
      </:item>
    </.menu>
    ```
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Focus management
    - Keyboard support
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          required: true,
          doc: """
          A accessibility label for the group. Set as `aria-label` attribute.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item, required: true do
          attr :role, :string,
            values: ["none", "separator"],
            doc: """
            Sets the role of the list item. If the item has a menu item, menu
            item radio group or menu item checkbox as a child, use `"none"`. If you
            want to render a visual separator, use `"separator"`. The default is
            `"none"`.
            """
        end
      end,
    heex:
      quote do
        ~H"""
        <ul class={@class} role="group" aria-label={@label} {@rest}>
          <li :for={item <- @item} role={item[:role] || "none"}>
            <%= if item[:role] != "separator" do %>
              <%= render_slot(item) %>
            <% end %>
          </li>
        </ul>
        """
      end
  )

  component(
    :menu_item,
    modifiers: [],
    doc: """
    Renders a button that acts as a menu item within a `menu/1` or `menu_bar/1`.

    A menu item is meant to be used to trigger an action. For a button that
    toggles the visibility of a menu, use `menu_button/1`.
    """,
    usage: """
    ```heex
    <.menu label="Actions">
      <:item>
        <.menu_item on_click={JS.dispatch("myapp:copy")}>
          Copy
        </.menu_item>
      </:item>
      <:item>
        <.menu_item on_click={JS.dispatch("myapp:paste")}>
          Paste
        </.menu_item>
      </:item>
    </.menu>
    ```
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
        attr :on_click, Phoenix.LiveView.JS, required: true
        attr :rest, :global

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <button
          class={@class}
          type="button"
          role="menuitem"
          phx-click={@on_click}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
        """
      end
  )

  component(
    :menu_item_checkbox,
    modifiers: [],
    doc: """
    Renders a menu item checkbox as part of a `menu/1` or `menu_bar/1`.

    See also `menu_item/1`.
    """,
    usage: """
    ```heex
    <.menu label="Actions">
      <:item>
        <.menu_item_checkbox on_click={JS.dispatch("myapp:toggle-word-wrap")}>
          Word wrap
        </.menu_item_checkbox>
      </:item>
    </.menu>
    ```
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - State management
    - Keyboard support
    """,
    attrs_and_slots:
      quote do
        attr :checked, :boolean, default: false
        attr :on_click, Phoenix.LiveView.JS, required: true
        attr :rest, :global

        slot :inner_block, required: true
      end,
    heex:
      quote do
        %{checked: checked} = var!(assigns)
        var!(assigns) = assign(var!(assigns), :checked, to_string(checked))

        ~H"""
        <div
          class={@class}
          role="menuitemcheckbox"
          aria-checked={@checked}
          phx-click={@on_click}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </div>
        """
      end
  )

  component(
    :menu_item_radio_group,
    modifiers: [],
    doc: """
    Renders a group of menu item radios as part of a `menu/1` or `menu_bar/1`.

    See also `menu_button/1`, `menu_item/1`, and `menu_item_checkbox/1`.
    """,
    usage: """
    ```heex
    <.menu id="actions-menu" labelledby="actions-button" hidden>
      <:item>
        <.menu_item_radio_group label="Theme">
          <:item on_click={JS.dispatch("switch-theme-light")}>
            Light
          </:item>
          <:item on_click={JS.dispatch("switch-theme-dark")} checked>
            Dark
          </:item>
        </.menu_item_radio_group>
      </:item>
    </.menu>
    ```
    """,
    type: :menu,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Focus management
    - State management
    - Keyboard support
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          required: true,
          doc: """
          A accessibility label for the group. Set as `aria-label` attribute.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item, required: true do
          attr :checked, :boolean
          attr :on_click, JS
        end
      end,
    heex:
      quote do
        ~H"""
        <ul class={@class} role="group" aria-label={@label} {@rest}>
          <li :for={item <- @item} role="none">
            <div
              role="menuitemradio"
              phx-click={item.on_click}
              aria-checked={to_string(item[:checked] || false)}
            >
              <%= render_slot(item) %>
            </div>
          </li>
        </ul>
        """
      end
  )

  component(
    :modal,
    modifiers: [],
    doc: """
    Renders a modal dialog for content such as forms and informational panels.

    This component is appropriate for non-critical interactions. For dialogs
    requiring immediate user response, such as confirmations or warnings, use
    `.alert_dialog/1` instead.
    """,
    usage: """
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

    ```heex
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
    ```

    To open the modal, patch or navigate to the URL associated with the live
    action.

    ```heex
    <.link patch={~p"/pets/\#{@id}"}>show</.link>
    ```

    ### Without URL

    To toggle the modal visibility dynamically with the `open` attribute:

    1. Omit the `open` attribute in the template.
    2. Use the `show_modal/1` and `hide_modal/1` functions to change the
       visibility.

    #### Example

    ```heex
    <.modal id="pet-modal">
      <:title>Show pet</:title>
      <p>My pet is called Johnny.</p>
      <:footer>
        <.link phx-click={JS.exec("data-cancel", to: "#pet-modal")}>
          Close
        </.link>
      </:footer>
    </.modal>
    ```

    To open modal, use the `show_modal/1` function.

    ```heex
    <.button
      phx-click={Doggo.show_modal("pet-modal")}
      aria-haspopup="dialog"
    >
      show
    </.button>
    ```

    ## CSS

    To hide the modal when the `open` attribute is not set, use the following CSS
    styles:

    ```css
    dialog.modal:not([open]),
    dialog.modal[open="false"] {
      display: none;
    }
    ```

    ## Semantics

    While the `showModal()` JavaScript function is typically recommended for
    managing modal dialog semantics, this component utilizes the `open` attribute
    to control visibility. This approach is chosen to eliminate the need for
    library consumers to add additional JavaScript code. To ensure proper
    modal semantics, the `aria-modal` attribute is added to the dialog element.
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :open, :boolean,
          default: false,
          doc: "Initializes the modal as open."

        attr :on_cancel, Phoenix.LiveView.JS,
          default: %Phoenix.LiveView.JS{},
          doc: """
          An additional `Phoenix.LiveView.JS` command to execute when the dialog
          is canceled. This command is executed in addition to closing the dialog. If
          you only want the dialog to be closed, you don't have to set this attribute.
          """

        attr :dismissable, :boolean,
          default: true,
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

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <dialog
          id={@id}
          class={@class}
          aria-modal={(@open && "true") || "false"}
          aria-labelledby={"#{@id}-title"}
          open={@open}
          phx-mounted={@open && Doggo.show_modal(@id)}
          phx-remove={Doggo.hide_modal(@id)}
          data-cancel={Phoenix.LiveView.JS.exec(@on_cancel, "phx-remove")}
          {@rest}
        >
          <.focus_wrap
            id={"#{@id}-container"}
            class={"#{@base_class}-container"}
            phx-window-keydown={
              @dismissable && Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")
            }
            phx-key={@dismissable && "escape"}
            phx-click-away={
              @dismissable && Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")
            }
          >
            <section>
              <header>
                <button
                  :if={@dismissable}
                  href="#"
                  class={"#{@base_class}-close"}
                  aria-label={@close_label}
                  phx-click={Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")}
                >
                  <%= render_slot(@close) %>
                  <span :if={@close == []}>close</span>
                </button>
                <h2 id={"#{@id}-title"}><%= render_slot(@title) %></h2>
              </header>
              <div id={"#{@id}-content"} class={"#{@base_class}-content"}>
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
  )

  component(
    :navbar,
    modifiers: [],
    doc: """
    Renders a navigation bar.
    """,
    usage: """
    ```heex
    <.navbar>
      <:brand><.link navigate={~p"/"}>Pet Clinic</.link></:brand>
      <.navbar_items>
        <:item><.link navigate={~p"/about"}>About</.link></:item>
        <:item><.link navigate={~p"/services"}>Services</.link></:item>
        <:item>
          <.link navigate={~p"/login"} class="button">Log in</.link>
        </:item>
      </.navbar_items>
    </.navbar>
    ```

    You can place multiple navigation item lists in the inner block. If the
    `.navbar` is styled as a flex box, you can use the CSS `order` property to
    control the display order of the brand and lists.

    ```heex
    <.navbar>
      <:brand><.link navigate={~p"/"}>Pet Clinic</.link></:brand>
      <.navbar_items class="navbar-main-links">
        <:item><.link navigate={~p"/about"}>About</.link></:item>
        <:item><.link navigate={~p"/services"}>Services</.link></:item>
      </.navbar_items>
      <.navbar_items class="navbar-user-menu">
        <:item>
          <.button_link navigate={~p"/login"}>Log in</.button_link>
        </:item>
      </.navbar_items>
    </.navbar>
    ```

    If you have multiple `<nav>` elements on your page, it is recommended to set
    the `aria-label` attribute.

    ```heex
    <.navbar aria-label="main navigation">
      <!-- ... -->
    </.navbar>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :label, :string,
          required: true,
          doc: """
          Aria label for the `<nav>` element (e.g. "Main"). The label is especially
          important if you have multiple `<nav>` elements on the same page. If the
          page is localized, the label should be translated, too. Do not include
          "navigation" in the label, since screen readers will already announce the
          "navigation" role as part of the label.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :brand, doc: "Slot for the brand name or logo."

        slot :inner_block,
          required: true,
          doc: """
          Slot for navbar items. Use the `navbar_items` component here to render
          navigation links or other controls.
          """
      end,
    heex:
      quote do
        ~H"""
        <nav class={@class} aria-label={@label} {@rest}>
          <div :if={@brand != []} class={"#{@base_class}-brand"}>
            <%= render_slot(@brand) %>
          </div>
          <%= render_slot(@inner_block) %>
        </nav>
        """
      end
  )

  component(
    :navbar_items,
    modifiers: [],
    doc: """
    Renders a list of navigation items.

    Meant to be used in the inner block of the `navbar` component.
    """,
    usage: """
    ```heex
    <.navbar_items>
      <:item><.link navigate={~p"/about"}>About</.link></:item>
      <:item><.link navigate={~p"/services"}>Services</.link></:item>
      <:item>
        <.link navigate={~p"/login"} class="button">Log in</.link>
      </:item>
    </.navbar_items>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :item,
          required: true,
          doc: "A navigation item, usually a link or a button." do
          attr :class, :string, doc: "A class for the `<li>`."
        end
      end,
    heex:
      quote do
        ~H"""
        <ul class={@class} {@rest}>
          <li :for={item <- @item} class={item[:class]}><%= render_slot(item) %></li>
        </ul>
        """
      end
  )

  component(
    :page_header,
    modifiers: [],
    doc: """
    Renders a header that is specific to the content of the current page.

    Unlike a site-wide header, which offers consistent navigation and elements
    like logos throughout the website or application, this component is meant
    to describe the unique content of each page. For instance, on an article page,
    it would display the article's title.

    It is typically used as a direct child of the `<main>` element.
    """,
    usage: """
    ```heex
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
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :title, :string,
          required: true,
          doc: "The title for the current page."

        attr :subtitle, :string, default: nil, doc: "An optional sub title."

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :action,
          doc: "A slot for action buttons related to the current page."
      end,
    heex:
      quote do
        ~H"""
        <header class={@class} {@rest}>
          <div class={"#{@base_class}-title"}>
            <h1><%= @title %></h1>
            <p :if={@subtitle}><%= @subtitle %></p>
          </div>
          <div :if={@action != []} class={"#{@base_class}-actions"}>
            <%= for action <- @action do %>
              <%= render_slot(action) %>
            <% end %>
          </div>
        </header>
        """
      end
  )

  component(
    :property_list,
    modifiers: [],
    doc: """
    Renders a list of properties, i.e. key/value pairs.
    """,
    usage: """
    ```heex
    <.property_list>
      <:prop label={gettext("Name")}>George</:prop>
      <:prop label={gettext("Age")}>42</:prop>
    </.property_list>
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :refining,
    attrs_and_slots:
      quote do
        slot :prop, doc: "A property to be rendered." do
          attr :label, :string, required: true
        end

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <dl class={@class} {@rest}>
          <div :for={prop <- @prop}>
            <dt><%= prop.label %></dt>
            <dd><%= render_slot(prop) %></dd>
          </div>
        </dl>
        """
      end
  )

  component(
    :radio_group,
    modifiers: [],
    doc: """
    Renders a group of radio buttons, for example for a toolbar.

    To render radio buttons within a regular form, use `input/1` with the
    `"radio-group"` type instead.
    """,
    usage: """
    ```heex
    <.radio_group
      id="favorite-dog"
      name="favorite-dog"
      label="Favorite Dog"
      options={[
        {"Labrador Retriever", "labrador"},
        {"German Shepherd", "german_shepherd"},
        {"Golden Retriever", "golden_retriever"},
        {"French Bulldog", "french_bulldog"},
        {"Beagle", "beagle"}
      ]}
    />
    ```

    ## CSS

    To target the wrapper, you can use an attribute selector:

    ```css
    [role="radio-group"] {}
    ```
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :name, :string,
          required: true,
          doc: "The `name` attribute for the `input` elements."

        attr :label, :string,
          default: nil,
          doc: """
          A accessibility label for the radio group. Set as `aria-label` attribute.

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          The DOM ID of an element that labels this radio group.

          Example:

          ```html
          <h3 id="dog-rg-label">Favorite Dog</h3>
          <.radio_group labelledby="dog-rg-label"></.radio_group>
          ```

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :options, :list,
          required: true,
          doc: """
          A list of options. It can be given a list values or as a list of
          `{label, value}` tuples.
          """

        attr :value, :any,
          default: nil,
          doc: """
          The currently selected value, which is compared with the option value to
          determine whether a radio button is checked.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".radio_group", "Favorite Dog")

        ~H"""
        <div
          id={@id}
          role="radiogroup"
          aria-label={@label}
          aria-labelledby={@labelledby}
          class={@class}
          {@rest}
        >
          <Doggo.Components.radio
            :for={option <- @options}
            option={option}
            name={@name}
            id={@id}
            value={@value}
            errors={[]}
            description={[]}
          />
        </div>
        """
      end
  )

  @doc false
  def radio(
        %{option_value: _, id: id, description: description, errors: errors} =
          assigns
      ) do
    assigns =
      assign(assigns,
        describedby: Doggo.input_aria_describedby(id, description),
        errormessage: Doggo.input_aria_errormessage(id, errors),
        invalid: errors != [] && "true"
      )

    ~H"""
    <Doggo.label>
      <input
        type="radio"
        name={@name}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={Doggo.checked?(@option_value, @value)}
        aria-describedby={@describedby}
        aria-errormessage={@errormessage}
        aria-invalid={@invalid}
      />
      <%= @label %>
    </Doggo.label>
    """
  end

  def radio(%{option: {option_label, option_value}} = assigns) do
    assigns
    |> assign(label: option_label, option_value: option_value, option: nil)
    |> radio()
  end

  def radio(%{option: option_value} = assigns) do
    assigns
    |> assign(
      label: Doggo.humanize(option_value),
      option_value: option_value,
      option: nil
    )
    |> radio()
  end

  component(
    :skeleton,
    modifiers: [
      type: [
        values: [
          "text-line",
          "text-block",
          "image",
          "circle",
          "rectangle",
          "square"
        ],
        required: true
      ]
    ],
    doc: """
    Renders a skeleton loader, a placeholder for content that is in the process of
    loading.

    It mimics the layout of the actual content, providing a better user experience
    during loading phases.
    """,
    usage: """
    Render one of the primitive types in isolation:

    ```heex
    <.skeleton type="text_line" />
    ```

    Combine primitives for complex layouts:

    ```heex
    <div class="card-skeleton" aria-busy="true">
      <.skeleton type="image" />
      <.skeleton type="text-line" />
      <.skeleton type="text-line" />
      <.skeleton type="text-line" />
      <.skeleton type="rectangle" />
    </div>
    ```

    To modify the primitives for your use cases, you can either configure additional
    modifiers or use CSS properties:

    ```heex
    <Doggo.skeleton type="text-line" variant="header" />
    ```

    ```heex
    <Doggo.skeleton type="image" style="--aspect-ratio: 75%;" />
    ```

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

    ```heex
    <.async_result :let={puppy} assign={@puppy}>
      <:loading><.card_skeleton /></:loading>
      <:failed :let={_reason}>There was an error loading the puppy.</:failed>
      <!-- Card for loaded content -->
    </.async_result>
    ```
    """,
    type: :feedback,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <div class={@class} {@rest}></div>
        """
      end
  )

  component(
    :split_pane,
    modifiers: [],
    doc: """
    Renders a horizontal or vertical resizable split pane.
    """,
    usage: """
    Horizontal separator with label:

    ```heex
    <.split_pane
      id="sidebar-splitter"
      label="Sidebar"
      orientation="horizontal"
    >
      <:primary>One</:primary>
      <:secondary>Two</:secondary>
    </.split_pane>
    ```

    Horizontal separator with visible label:

    ```heex
    <.split_pane id="sidebar-splitter"
      labelledby="sidebar-label"
      orientation="horizontal"
    >
      <:primary>
        <h2 id="sidebar-label">Sidebar</h2>
        <p>One</p>
      </:primary>
      <:secondary>Two</:secondary>
    </.split_pane>
    ```

    Nested window splitters:

    ```heex
    <.split_pane
      id="sidebar-splitter"
      label="Sidebar"
      orientation="horizontal"
    >
      <:primary>One</:primary>
      <:secondary>
        <.split_pane
          id="filter-splitter"
          label="Filters"
          orientation="vertical"
        >
          <:primary>Two</:primary>
          <:secondary>Three</:secondary>
        </.split_pane>
      </:secondary>
    </.split_pane>
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Resize panes with the mouse
    - Resize panes with the keyboard
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: nil,
          doc: """
          An accessibility label for the separator if the primary pane has no visible
          label. If it has a visible label, set the `labelledby` attribute instead.

          Note that the label should describe the primary pane, not the resize handle.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          If the primary pane has a visible label, set this attribute to the DOM ID
          of that label. Otherwise, provide a label via the `label` attribute.
          """

        attr :id, :string, required: true

        attr :orientation, :string,
          values: ["horizontal", "vertical"],
          required: true

        attr :default_size, :integer, required: true
        attr :min_size, :integer, default: 0
        attr :max_size, :integer, default: 100
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :primary, required: true
        slot :secondary, required: true
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".split_pane", "Sidebar")

        ~H"""
        <div id={@id} class={@class} data-orientation={@orientation} {@rest}>
          <div id={"#{@id}-primary"}><%= render_slot(@primary) %></div>
          <div
            role="separator"
            aria-label={@label}
            aria-labelledby={@labelledby}
            aria-controls={"#{@id}-primary"}
            aria-orientation={@orientation}
            aria-valuenow={@default_size}
            aria-valuemin={@min_size}
            aria-valuemax={@max_size}
          >
          </div>
          <div id={"#{@id}-secondary"}><%= render_slot(@secondary) %></div>
        </div>
        """
      end
  )

  component(
    :steps,
    modifiers: [],
    extra: [
      current_class: "is-current",
      completed_class: "is-completed",
      upcoming_class: "is-upcoming",
      visually_hidden_class: "is-visually-hidden"
    ],
    doc: """
    Renders a navigation for form steps.
    """,
    usage: """
    With patch navigation:

    ```heex
    <.steps current_step={0}>
      <:step on_click={JS.patch(to: ~p"/form/step/personal-information")}>
        Profile
      </:step>
      <:step on_click={JS.patch(to: ~p"/form/step/delivery")}>
        Delivery
      </:step>
      <:step on_click={JS.patch(to: ~p"/form/step/confirmation")}>
        Confirmation
      </:step>
    </.steps>
    ```

    With push events:

    ```heex
    <.steps current_step={0}>
      <:step on_click={JS.push("go-to-step", value: %{step: "profile"})}>
        Profile
      </:step>
      <:step on_click={JS.push("go-to-step", value: %{step: "delivery"})}>
        Delivery
      </:step>
      <:step on_click={JS.push("go-to-step", value: %{step: "confirmation"})}>
        Confirmation
      </:step>
    </.steps>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :label, :string, default: "Form steps"

        attr :current_step, :integer,
          required: true,
          doc: """
          The current form step, zero-based index.
          """

        attr :completed_label, :string,
          default: "Completed: ",
          doc: """
          Visually hidden text that is rendered for screen readers for completed
          steps.
          """

        attr :linear, :boolean,
          default: false,
          doc: """
          If `true`, clickable links are only rendered for completed steps.

          If `false`, also upcoming steps are clickable.

          If you don't want any clickable links to be rendered, omit the `on_click`
          attribute on the `:step` slots.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :step, required: true do
          attr :on_click, :any,
            doc: """
            Event name or `Phoenix.LiveView.JS` command to execute when clicking on
            the step.
            """
        end
      end,
    heex: fn extra ->
      current_class = Keyword.fetch!(extra, :current_class)
      completed_class = Keyword.fetch!(extra, :completed_class)
      upcoming_class = Keyword.fetch!(extra, :upcoming_class)
      visually_hidden_class = Keyword.fetch!(extra, :visually_hidden_class)

      quote do
        var!(assigns) =
          assign(var!(assigns),
            current_class: unquote(current_class),
            completed_class: unquote(completed_class),
            upcoming_class: unquote(upcoming_class),
            visually_hidden_class: unquote(visually_hidden_class)
          )

        ~H"""
        <nav aria-label={@label} class={@class} {@rest}>
          <ol>
            <Doggo.Components.step
              :for={{step, index} <- Enum.with_index(@step)}
              step={step}
              index={index}
              current_step={@current_step}
              current_class={@current_class}
              completed_class={@completed_class}
              upcoming_class={@upcoming_class}
              visually_hidden_class={@visually_hidden_class}
              completed_label={@completed_label}
              linear={@linear}
            />
          </ol>
        </nav>
        """
      end
    end
  )

  @doc false
  def step(
        %{
          index: index,
          current_step: current_step,
          current_class: current_class,
          completed_class: completed_class,
          upcoming_class: upcoming_class
        } = assigns
      ) do
    class =
      cond do
        index == current_step -> current_class
        index < current_step -> completed_class
        index > current_step -> upcoming_class
      end

    assigns =
      assign(assigns,
        class: class,
        current_class: nil,
        completed_class: nil,
        upcoming_class: nil
      )

    ~H"""
    <li class={@class} aria-current={@index == @current_step && "step"}>
      <span :if={@index < @current_step} class={@visually_hidden_class}>
        <%= @completed_label %>
      </span>
      <%= if @step[:on_click] && ((@linear && @index < @current_step) || (!@linear && @index != @current_step)) do %>
        <.link phx-click={@step[:on_click]}>
          <%= render_slot(@step) %>
        </.link>
      <% else %>
        <span><%= render_slot(@step) %></span>
      <% end %>
    </li>
    """
  end

  component(
    :switch,
    modifiers: [],
    doc: """
    Renders a switch as a button.

    If you want to render a switch as part of a form, use the `input/1` component
    with the type `"switch"` instead.

    Note that this component only renders a button with a label, a state, and
    `<span>` with the class `switch-control`. You will need to style the switch
    control span with CSS in order to give it the appearance of a switch.
    """,
    usage: """
    ```heex
    <.switch
      label="Subscribe"
      checked={true}
      phx-click="toggle-subscription"
    />
    ```
    """,
    type: :buttons,
    since: "0.6.0",
    maturity: :experimental,
    attrs_and_slots:
      quote do
        attr :label, :string, required: true
        attr :on_text, :string, default: "On"
        attr :off_text, :string, default: "Off"
        attr :checked, :boolean, default: false
        attr :rest, :global
      end,
    heex:
      quote do
        ~H"""
        <button
          class={@class}
          type="button"
          role="switch"
          aria-checked={to_string(@checked)}
          {@rest}
        >
          <span class={"#{@base_class}-label"}><%= @label %></span>
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
                <%= @on_text %>
              <% else %>
                <%= @off_text %>
              <% end %>
            </span>
          </span>
        </button>
        """
      end
  )

  component(
    :stack,
    modifiers: [],
    extra: [recursive_class: "is-recursive"],
    doc: """
    Applies a vertical margin between the child elements.
    """,
    usage: """
    ```heex
    <.stack>
      <div>some block</div>
      <div>some other block</div>
    </.stack>
    ```

    To apply a vertical margin on nested elements as well, set `recursive` to
    `true`.

    ```heex
    <.stack recursive={true}>
      <div>
        <div>some nested block</div>
        <div>another nested block</div>
      </div>
      <div>some other block</div>
    </.stack>
    ```
    """,
    type: :layout,
    since: "0.6.0",
    maturity: :refining,
    attrs_and_slots:
      quote do
        attr :recursive, :boolean,
          default: false,
          doc:
            "If `true`, the stack margins will be applied to nested elements as well."

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block, required: true
      end,
    heex: fn extra ->
      recursive_class = Keyword.fetch!(extra, :recursive_class)

      quote do
        var!(assigns) =
          if var!(assigns)[:recursive] do
            Map.update!(
              var!(assigns),
              :class,
              &(&1 ++ [unquote(recursive_class)])
            )
          else
            var!(assigns)
          end

        ~H"""
        <div class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </div>
        """
      end
    end
  )

  component(
    :tab_navigation,
    modifiers: [],
    doc: """
    Renders navigation tabs.

    This component is meant for tabs that link to a different view or live action.
    If you want to render tabs that switch between in-page content panels, use
    `tabs/1` instead.
    """,
    usage: """
    ```heex
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
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: "Tabs",
          doc: """
          Aria label for the `<nav>` element. The label is especially important if you
          have multiple `<nav>` elements on the same page. If the page is localized,
          the label should be translated, too. Do not include "navigation" in the
          label, since screen readers will already announce the "navigation" role as
          part of the label.
          """

        attr :current_value, :any,
          required: true,
          doc: """
          The current value used to compare the item values with. If you use this
          component to patch between different view actions, this could be the
          `@live_action` attribute.
          """

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
      end,
    heex:
      quote do
        ~H"""
        <nav aria-label={@label} class={@class} {@rest}>
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
  )

  component(
    :table,
    base_class: "table-container",
    modifiers: [],
    doc: """
    Renders a simple table.
    """,
    usage: """
    ```heex
    <.table id="pets" rows={@pets}>
      <:col :let={p} label="name"><%= p.name %></:col>
      <:col :let={p} label="age"><%= p.age %></:col>
    </.table>
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
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

        attr :row_click, :any,
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

        attr :rest, :global, doc: "Any additional HTML attributes."

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

          attr :col_attrs, :list,
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

          attr :col_attrs, :list,
            doc: """
            If set, a `<colgroup>` element is rendered and the attributes are added
            to the `<col>` element of the respective column.
            """
        end

        slot :foot,
          doc: """
          You can optionally add a `foot`. The inner block will be rendered inside
          a `tfoot` element.

              <Flop.Phoenix.table>
                <:foot>
                  <tr><td>Total: <span class="total"><%= @total %></span></td></tr>
                </:foot>
              </Flop.Phoenix.table>
          """
      end,
    heex:
      quote do
        var!(assigns) =
          with %{rows: %Phoenix.LiveView.LiveStream{}} <- var!(assigns) do
            assign(var!(assigns),
              row_id: var!(assigns).row_id || fn {id, _item} -> id end
            )
          end

        ~H"""
        <div class={@class} {@rest}>
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
  )

  component(
    :tabs,
    modifiers: [],
    doc: """
    Renders tab panels.

    This component is meant for tabs that toggle content panels within the page.
    If you want to link to a different view or live action, use
    `tab_navigation/1` instead.
    """,
    usage: """
    ```heex
    <.tabs id="dog-breed-profiles" label="Dog Breed Profiles">
      <:panel label="Golden Retriever">
        <p>
          Friendly, intelligent, great with families. Origin: Scotland. Needs
          regular exercise.
        </p>
      </:panel>
      <:panel label="Siberian Husky">
        <p>
          Energetic, outgoing, distinctive appearance. Origin: Northeast Asia.
          Loves cold climates.
        </p>
      </:panel>
      <:panel label="Dachshund">
        <p>
          Playful, stubborn, small size. Origin: Germany. Enjoys sniffing games.
        </p>
      </:panel>
    </.tabs>
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Roving tabindex
    - Move focus with arrow keys
    """,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :label, :string,
          default: nil,
          doc: """
          A accessibility label for the tabs. Set as `aria-label` attribute.

          You should ensure that either the `label` or the `labelledby` attribute is
          set.

          Do not repeat the word `tab list` or similar in the label, since it is
          already announced by screen readers.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          The DOM ID of an element that labels the tabs.

          Example:

          ```html
          <h3 id="my-tabs-label">Dogs</h3>
          <Doggo.tabs labelledby="my-tabs-label"></Doggo.tabs>
          ```

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :panel, required: true do
          attr :label, :string
        end
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".tabs", "Dog Facts")

        ~H"""
        <div id={@id} class={@class} {@rest}>
          <div role="tablist" aria-label={@label} aria-labelledby={@labelledby}>
            <button
              :for={{panel, index} <- Enum.with_index(@panel, 1)}
              type="button"
              role="tab"
              id={"#{@id}-tab-#{index}"}
              aria-selected={to_string(index == 1)}
              aria-controls={"#{@id}-panel-#{index}"}
              tabindex={index != 1 && "-1"}
              phx-click={Doggo.show_tab(@id, index)}
            >
              <%= panel.label %>
            </button>
          </div>
          <div
            :for={{panel, index} <- Enum.with_index(@panel, 1)}
            id={"#{@id}-panel-#{index}"}
            role="tabpanel"
            aria-labelledby={"#{@id}-tab-#{index}"}
            hidden={index != 1}
          >
            <%= render_slot(panel) %>
          </div>
        </div>
        """
      end
  )

  component(
    :tag,
    modifiers: [
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      variant: [
        values: [
          nil,
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: nil
      ],
      shape: [values: [nil, "pill"], default: nil]
    ],
    doc: """
    Renders a tag, typically used for displaying labels, categories, or keywords.
    """,
    usage: """
    ```heex
    <.tag>Well-Trained</.tag>
    ```

    With icon:

    ```heex
    <.tag>
      Puppy
      <.icon><Heroicons.edit /></.icon>
    </.tag>
    ```

    With delete button:

    ```heex
    <.tag>
      High Energy
      <.button
        phx-click="remove-tag"
        phx-value-tag="high-energy"
        aria-label="Remove tag"
      >
        <.icon><Heroicons.x /></.icon>
      </.button>
    </.tag>
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :refining,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <span class={@class} {@rest}>
          <%= render_slot(@inner_block) %>
        </span>
        """
      end
  )

  component(
    :time,
    base_class: nil,
    modifiers: [],
    doc: """
    Renders a `Time`, `DateTime`, or `NaiveDateTime` in a `<time>` tag.
    """,
    usage: """
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
    """,
    type: :data,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :value, :any,
          required: true,
          doc: """
          Either a `Time`, `DateTime`, or `NaiveDateTime`.
          """

        attr :formatter, :any,
          default: nil,
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

        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        %{
          value: value,
          precision: precision,
          timezone: timezone,
          formatter: formatter,
          title_formatter: title_formatter
        } = var!(assigns)

        formatter = formatter || (&to_string/1)

        value =
          value
          |> Doggo.shift_zone(timezone)
          |> Doggo.truncate_datetime(precision)
          |> Doggo.to_time()

        var!(assigns) =
          assigns
          |> var!()
          |> assign(:datetime, value && Time.to_iso8601(value))
          |> assign(
            :title,
            value && Doggo.time_title_attr(value, title_formatter)
          )
          |> assign(:value, value && formatter.(value))

        ~H"""
        <time :if={@value} class={@class} datetime={@datetime} title={@title} {@rest}>
          <%= @value %>
        </time>
        """
      end
  )

  component(
    :toggle_button,
    base_class: "button",
    modifiers: [
      variant: [
        values: [
          "primary",
          "secondary",
          "info",
          "success",
          "warning",
          "danger"
        ],
        default: "primary"
      ],
      size: [values: ["small", "normal", "medium", "large"], default: "normal"],
      fill: [values: ["solid", "outline", "text"], default: "solid"],
      shape: [values: [nil, "circle", "pill"], default: nil]
    ],
    doc: """
    Renders a button that toggles a state.

    Use this component to switch a feature or setting on or off, for example to
    toggle dark mode or mute/unmute sound.

    See also `button/1`, `button_link/1`, and `disclosure_button/1`.
    """,
    usage: """
    With a `Phoenix.LiveView.JS` command:

    ```heex
    <.toggle_button on_click={JS.push("toggle-mute")} pressed={@muted}>
      Mute
    </.toggle_button>
    ```

    ## Accessibility

    The button state is conveyed via the `aria-pressed` attribute and the button
    styling. The button text should not change depending on the state. You may
    however include an icon that changes depending on the state.

    ## CSS

    A toggle button can be identified with an attribute selector for the
    `aria-pressed` attribute.

    ```css
    // any toggle button regardless of state
    button[aria-pressed] {}

    // unpressed toggle buttons
    button[aria-pressed="false"] {}

    // pressed toggle buttons
    button[aria-pressed="true"] {}
    ```
    """,
    type: :buttons,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :pressed, :boolean, default: false

        attr :on_click, Phoenix.LiveView.JS,
          required: true,
          doc: """
          `Phoenix.LiveView.JS` command or event name to trigger when the button is
          clicked.
          """

        attr :disabled, :boolean, default: nil
        attr :rest, :global

        slot :inner_block, required: true
      end,
    heex:
      quote do
        %{pressed: pressed} = var!(assigns)
        var!(assigns) = assign(var!(assigns), :pressed, to_string(pressed))

        ~H"""
        <button
          type="button"
          phx-click={
            Phoenix.LiveView.JS.toggle_attribute(
              @on_click,
              {"aria-pressed", "true", "false"}
            )
          }
          aria-pressed={@pressed}
          class={@class}
          disabled={@disabled}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
        """
      end
  )

  component(
    :toolbar,
    modifiers: [],
    doc: """
    Renders a container for a set of controls.
    """,
    usage: """
    Direct children of this component can be any types buttons or groups of
    buttons.

    ```heex
    <.toolbar label="Actions for the dog">
      <div role="group">
        <button phx-click="feed-dog">
          <.icon label="Feed dog"><Icons.feed /></.icon>
        </button>
        <button phx-click="walk-dog">
          <.icon label="Walk dog"><Icons.walk /></.icon>
        </button>
      </div>
      <div role="group">
        <button phx-click="teach-trick">
          <.icon label="Teach a Trick"><Icons.teach /></.icon>
        </button>
        <button phx-click="groom-dog">
          <.icon label="Groom dog"><Icons.groom /></.icon>
        </button>
      </div>
    </.toolbar>
    ```
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Roving tabindex
    - Move focus with arrow keys
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: nil,
          doc: """
          A accessibility label for the toolbar. Set as `aria-label` attribute.

          You should ensure that either the `label` or the `labelledby` attribute is
          set.

          Do not repeat the word `toolbar` in the label, since it is already announced
          by screen readers.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          The DOM ID of an element that labels this tree.

          Example:

          ```html
          <h3 id="dog-toolbar-label">Dogs</h3>
          <Doggo.toolbar labelledby="dog-toolbar-label"></Doggo.toolbar>
          ```

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :controls, :string,
          default: nil,
          doc: """
          DOM ID of the element that is controlled by this toolbar. For example,
          if the toolbar provides text formatting options for an editable content
          area, the values should be the ID of that content area.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block,
          required: true,
          doc: """
          Place any number of buttons, groups of buttons, toggle buttons, menu
          buttons, or disclosure buttons here.
          """
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".toolbar", "Dog profile actions")

        ~H"""
        <div
          class={@class}
          role="toolbar"
          aria-label={@label}
          aria-labelledby={@labelledby}
          aria-controls={@controls}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </div>
        """
      end
  )

  component(
    :tooltip,
    base_class: "tooltip-container",
    modifiers: [],
    doc: """
    Renders content with a tooltip.

    There are different ways to render a tooltip. This component renders a `<div>`
    with the `tooltip` role, which is hidden unless the element is hovered on or
    focused. For example CSS for this kind of tooltip, refer to
    [ARIA: tooltip role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/tooltip_role).

    A simpler alternative for styled text-only tooltips is to use a data attribute
    and the [`attr` CSS function](https://developer.mozilla.org/en-US/docs/Web/CSS/attr).
    Doggo does not provide a component for that kind of tooltip, since it is
    controlled by attributes only. You can check
    [Pico CSS](https://picocss.com/docs/tooltip) for an example implementation.
    """,
    usage: """
    With an inline text:

    ```heex
    <p>
      Did you know that the
      <.tooltip id="labrador-info">
        Labrador Retriever
        <:tooltip>
          <p><strong>Labrador Retriever</strong></p>
          <p>
            Labradors are known for their friendly nature and excellent
            swimming abilities.
          </p>
        </:tooltip>
      </.tooltip>
      is one of the most popular dog breeds in the world?
    </p>
    ```

    If the inner block contains a link, add the `:contains_link` attribute:

    ```heex
    <p>
      Did you know that the
      <.tooltip id="labrador-info" contains_link>
        <.link navigate={~p"/labradors"}>Labrador Retriever</.link>
        <:tooltip>
          <p><strong>Labrador Retriever</strong></p>
          <p>
            Labradors are known for their friendly nature and excellent
            swimming abilities.
          </p>
        </:tooltip>
      </.tooltip>
      is one of the most popular dog breeds in the world?
    </p>
    ```
    """,
    type: :miscellaneous,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :contains_link, :boolean,
          default: false,
          doc: """
          If `false`, the component sets `tabindex="0"` on the element wrapping the
          inner block, so that the tooltip can be made visible by focusing the
          element.

          If the inner block already contains an element that is focusable, such as
          a link or a button, set this attribute to `true`.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block, required: true
        slot :tooltip, required: true
      end,
    heex:
      quote do
        ~H"""
        <span
          class={@class}
          aria-describedby={"#{@id}-tooltip"}
          data-aria-tooltip
          {@rest}
        >
          <span tabindex={!@contains_link && "0"}>
            <%= render_slot(@inner_block) %>
          </span>
          <div role="tooltip" id={"#{@id}-tooltip"}>
            <%= render_slot(@tooltip) %>
          </div>
        </span>
        """
      end
  )

  component(
    :tree,
    modifiers: [],
    doc: """
    Renders a hierarchical list as a tree.

    A good use case for this component is a folder structure. For navigation and
    other menus, a regular nested list should be preferred.
    """,
    usage: """
    ```heex
    <.tree label="Dogs">
      <tree_item>
        Breeds
        <:items>
          <.tree_item>Golden Retriever</.tree_item>
          <.tree_item>Labrador Retriever</.tree_item>
        </:items>
      </.tree_item>
      <.tree_item>
        Characteristics
        <:items>
          <.tree_item>Playful</.tree_item>
          <.tree_item>Loyal</.tree_item>
        </:items>
      </.tree_item>
    </.tree>
    ```

    ## CSS

    You can target the wrapper with an attribute selector for the role:

    ```css
    [role="tree"] {}
    ```
    """,
    type: :data,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing features**

    - Expand and collapse nodes
    - Select nodes
    - Navigate tree with arrow keys
    """,
    attrs_and_slots:
      quote do
        attr :label, :string,
          default: nil,
          doc: """
          A accessibility label for the tree. Set as `aria-label` attribute.

          You should ensure that either the `label` or the `labelledby` attribute is
          set.

          Do not repeat the word `tree` in the label, since it is already announced
          by screen readers.
          """

        attr :labelledby, :string,
          default: nil,
          doc: """
          The DOM ID of an element that labels this tree.

          Example:

          ```html
          <h3 id="dog-tree-label">Dogs</h3>
          <.tree labelledby="dog-tree-label"></.tree>
          ```

          You should ensure that either the `label` or the `labelledby` attribute is
          set.
          """

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :inner_block,
          required: true,
          doc: """
          Slot for the root nodes of the tree. Use the `tree_item/1` component as
          direct children.
          """
      end,
    heex:
      quote do
        Doggo.ensure_label!(var!(assigns), ".tree", "Dog Breeds")

        ~H"""
        <ul
          class={@class}
          role="tree"
          aria-label={@label}
          aria-labelledby={@labelledby}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </ul>
        """
      end
  )

  component(
    :tree_item,
    modifiers: [],
    doc: """
    Renders a tree item within a `tree/1`.

    This component can be used as a direct child of `tree/1` or within the `items`
    slot of this component.
    """,
    usage: """
    ```heex
    <.tree label="Dogs">
      <.tree_item>
        Breeds
        <:items>
          <.tree_item>Golden Retriever</.tree_item>
          <.tree_item>Labrador Retriever</.tree_item>
        </:items>
      </.tree_item>
      <.tree_item>
        Characteristics
        <:items>
          <.tree_item>Playful</.tree_item>
          <.tree_item>Loyal</.tree_item>
        </:items>
      </.tree_item>
    </.tree>
    ```

    Icons can be added before the label:

    <.tree_item>
      <Heroicon.folder /> Breeds
      <:items>
        <.tree_item><Heroicon.document /> Golden Retriever</.tree_item>
        <.tree_item><Heroicon.document /> Labrador Retriever</.tree_item>
      </:items>
    </.tree_item>
    """,
    type: :data,
    since: "0.6.0",
    maturity: :experimental,
    maturity_note: """
    The necessary JavaScript for making this component fully functional and
    accessible will be added in a future version.

    **Missing featumres**

    - Expand and collapse nodes
    - Select nodes
    - Navigate tree with arrow keys
    """,
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :items,
          doc: """
          Slot for children of this item. Place one or more additional `tree_item/1`
          components within this slot, or omit if this is a leaf node.
          """

        slot :inner_block,
          required: true,
          doc: """
          Slot for the item label.
          """
      end,
    heex:
      quote do
        ~H"""
        <li
          class={@class}
          role="treeitem"
          aria-selected="false"
          aria-expanded={@items != [] && "false"}
          {@rest}
        >
          <span><%= render_slot(@inner_block) %></span>
          <ul :if={@items != []} role="group">
            <%= render_slot(@items) %>
          </ul>
        </li>
        """
      end
  )

  component(
    :vertical_nav,
    modifiers: [],
    doc: """
    Renders a vertical navigation menu.

    It is commonly placed within drawers or sidebars.

    For hierarchical menu structures, use `vertical_nav_nested/1` within the
    `:item` slot.

    To include sections in your drawer or sidebar that are not part of the
    navigation menu (like informational text or a site search), use the
    `vertical_nav_section/1` component.
    """,
    usage: """
    ```heex
    <.vertical_nav label="Main">
      <:item>
        <.link navigate={~p"/dashboard"}>Dashboard</.link>
      </:item>
      <:item>
        <.vertical_nav_nested>
          <:title>Content</:title>
          <:item current_page>
            <.link navigate={~p"/posts"}>Posts</.link>
          </:item>
          <:item>
            <.link navigate={~p"/comments"}>Comments</.link>
          </:item>
        </.vertical_nav_nested>
      </:item>
    </.vertical_nav>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, default: nil
        attr :label, :string, required: true
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :title, doc: "An optional slot for the title of the menu."

        slot :item, required: true, doc: "Items" do
          attr :class, :string
          attr :current_page, :boolean
        end
      end,
    heex:
      quote do
        ~H"""
        <nav class={@class} id={@id} aria-label={@label} {@rest}>
          <div :if={@title != []} class={"#{@base_class}-title"}>
            <%= render_slot(@title) %>
          </div>
          <ul>
            <li
              :for={item <- @item}
              class={item[:class]}
              aria-current={item[:current_page] && "page"}
            >
              <%= render_slot(item) %>
            </li>
          </ul>
        </nav>
        """
      end
  )

  component(
    :vertical_nav_nested,
    modifiers: [],
    doc: """
    Renders nested navigation items within the `:item` slot of the
    `vertical_nav/1` component.
    """,
    usage: """
    ```heex
    <.vertical_nav label="Main">
      <:item>
        <.vertical_nav_nested>
          <:title>Content</:title>
          <:item current_page>
            <.link navigate={~p"/posts"}>Posts</.link>
          </:item>
          <:item>
            <.link navigate={~p"/comments"}>Comments</.link>
          </:item>
        </.vertical_nav_nested>
      </:item>
    </.vertical_nav>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true
        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :title,
          doc: "An optional slot for the title of the nested menu section."

        slot :item, required: true, doc: "Items" do
          attr :class, :string
          attr :current_page, :boolean
        end
      end,
    heex:
      quote do
        ~H"""
        <div class={@class} {@rest}>
          <div :if={@title != []} id={"#{@id}-title"} class={"#{@base_class}-title"}>
            <%= render_slot(@title) %>
          </div>
          <ul id={@id} aria-labelledby={@title != [] && "#{@id}-title"}>
            <li
              :for={item <- @item}
              class={item[:class]}
              aria-current={item[:current_page] && "page"}
            >
              <%= render_slot(item) %>
            </li>
          </ul>
        </div>
        """
      end
  )

  component(
    :vertical_nav_section,
    modifiers: [],
    doc: """
    Renders a section within a sidebar or drawer that contains one or more
    items which are not navigation links.

    To render navigation links, use `vertical_nav/1` instead.
    """,
    usage: """
    ```heex
    <.vertical_nav_section>
      <:title>Search</:title>
      <:item><input type="search" placeholder="Search" /></:item>
    </.vertical_nav_section>
    ```
    """,
    type: :navigation,
    since: "0.6.0",
    maturity: :developing,
    attrs_and_slots:
      quote do
        attr :id, :string, required: true

        attr :rest, :global, doc: "Any additional HTML attributes."

        slot :title, doc: "An optional slot for the title of the section."

        slot :item, required: true, doc: "Items" do
          attr :class, :any,
            doc: "Additional CSS classes. Can be a string or a list of strings."
        end
      end,
    heex:
      quote do
        ~H"""
        <div
          id={@id}
          class={@class}
          aria-labelledby={@title != [] && "#{@id}-title"}
          {@rest}
        >
          <div :if={@title != []} id={"#{@id}-title"} class={"#{@base_class}-title"}>
            <%= render_slot(@title) %>
          </div>
          <div
            :for={item <- @item}
            class={["#{@base_class}-item" | List.wrap(item[:class] || [])]}
          >
            <%= render_slot(item) %>
          </div>
        </div>
        """
      end
  )
end
