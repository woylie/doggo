defmodule Doggo.Components do
  @moduledoc """
  This module defines macros that generate customized components.

  ## Usage

  Import this module, ensure you also use `Phoenix.Component`, and call the
  macros of all the components you need.

  To generate all components with their default options:

      defmodule MyAppWeb.CoreComponents do
        use Phoenix.Component
        import Doggo.Components

        accordion()
        action_bar()
        alert_dialog()
        app_bar()
        badge()
        bottom_navigation()
        box()
        breadcrumb()
        button()
        button_link()
        cluster()
        disclosure_button()
        fab()
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
        toggle_button()
        toolbar()
        tooltip()
        tree()
        tree_item()
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
    modifiers.
  - `class_name_fun` - A 1-arity function that takes a modifier attribute value
    and returns a CSS class name. Defaults to `Doggo.modifier_class_name/1`.
  """

  use Phoenix.Component

  import Doggo.Macros

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
    type: :component,
    since: "0.6.0",
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
        <div id={@id} class={[@base_class | @modifier_classes]} {@rest}>
          <div :for={{section, index} <- Enum.with_index(@section, 1)}>
            <.dynamic_tag name={@heading}>
              <button
                id={"#{@id}-trigger-#{index}"}
                type="button"
                aria-expanded={
                  to_string(
                    Doggo.Components.accordion_section_expanded?(index, @expanded)
                  )
                }
                aria-controls={"#{@id}-section-#{index}"}
                phx-click={Doggo.toggle_accordion_section(@id, index)}
              >
                <span><%= section.title %></span>
              </button>
            </.dynamic_tag>
            <div
              id={"#{@id}-section-#{index}"}
              role="region"
              aria-labelledby={"#{@id}-trigger-#{index}"}
              hidden={!Doggo.Components.accordion_section_expanded?(index, @expanded)}
            >
              <%= render_slot(section) %>
            </div>
          </div>
        </div>
        """
      end
  )

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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Roving tabindex
    > - Move focus with arrow keys
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
    type: :component,
    since: "0.6.0",
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
        <div role="toolbar" class={[@base_class | @modifier_classes]} {@rest}>
          <button :for={item <- @item} phx-click={item.on_click} title={item.label}>
            <%= render_slot(item) %>
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
          aria-modal={(@open && "true") || "false"}
          aria-labelledby={"#{@id}-title"}
          aria-describedby={"#{@id}-content"}
          open={@open}
          phx-mounted={@open && Doggo.show_modal(@id)}
          phx-remove={Doggo.hide_modal(@id)}
          data-cancel={JS.exec(@on_cancel, "phx-remove")}
          {@rest}
        >
          <.focus_wrap
            id={"#{@id}-container"}
            class="alert-dialog-container"
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
    type: :navigation,
    since: "0.6.0",
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
        <header class={[@base_class | @modifier_classes]} {@rest}>
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
  )

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
    type: :component,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <span class={[@base_class | @modifier_classes]} {@rest}>
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
        <nav aria-label={@label} class={[@base_class | @modifier_classes]} {@rest}>
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
    type: :component,
    since: "0.6.0",
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
        <section class={[@base_class | @modifier_classes]} {@rest}>
          <header :if={@title != [] || @banner != [] || @action != []}>
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
        <nav aria-label={@label} class={[@base_class | @modifier_classes]} {@rest}>
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
    type: :button,
    since: "0.6.0",
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
        <button
          type={@type}
          class={[@base_class | @modifier_classes]}
          disabled={@disabled}
          {@rest}
        >
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
    type: :button,
    since: "0.6.0",
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
          assign(
            var!(assigns),
            :disabled_class,
            var!(assigns)[:disabled] && unquote(disabled_class)
          )

        ~H"""
        <.link class={[@base_class | @modifier_classes] ++ [@disabled_class]} {@rest}>
          <%= render_slot(@inner_block) %>
        </.link>
        """
      end
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
    type: :component,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <div class={[@base_class | @modifier_classes]} {@rest}>
          <%= render_slot(@inner_block) %>
        </div>
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
    type: :button,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :controls, :string,
          required: true,
          doc: """
          The DOM ID of the element that this button controls.
          """

        attr :rest, :global

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
          class={[@base_class | @modifier_classes]}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
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
    type: :button,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :label, :string, required: true
        attr :disabled, :boolean, default: false
        attr :rest, :global

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <button
          type="button"
          aria-label={@label}
          class={[@base_class | @modifier_classes]}
          disabled={@disabled}
          {@rest}
        >
          <%= render_slot(@inner_block) %>
        </button>
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Focus management
    > - keyboard support
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
          class={[@base_class | @modifier_classes]}
          role="menu"
          aria-label={@label}
          aria-labelledby={@labelledby}
          {@rest}
        >
          <li :for={item <- @item} role={Map.get(item, :role, "none")}>
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Focus management
    > - keyboard support
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
          class={[@base_class | @modifier_classes]}
          role="menubar"
          aria-label={@label}
          aria-labelledby={@labelledby}
          {@rest}
        >
          <li :for={item <- @item} role={Map.get(item, :role, "none")}>
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
          class={[@base_class | @modifier_classes]}
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Focus management
    > - Keyboard support
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
        <ul
          class={[@base_class | @modifier_classes]}
          role="group"
          aria-label={@label}
          {@rest}
        >
          <li :for={item <- @item} role={Map.get(item, :role, "none")}>
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
          class={[@base_class | @modifier_classes]}
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - State management
    > - Keyboard support
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
    attrs_and_slots:
      quote do
        attr :checked, :boolean, default: false
        attr :on_click, Phoenix.LiveView.JS, required: true
        attr :rest, :global

        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <div
          class={[@base_class | @modifier_classes]}
          role="menuitemcheckbox"
          aria-checked={to_string(@checked)}
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Focus management
    > - State management
    > - Keyboard support
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
        <ul
          class={[@base_class | @modifier_classes]}
          role="group"
          aria-label={@label}
          {@rest}
        >
          <li :for={item <- @item} role="none">
            <div
              role="menuitemradio"
              phx-click={item.on_click}
              aria-checked={item |> Map.get(:checked, false) |> to_string()}
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
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
            class="modal-container"
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
                  class="modal-close"
                  aria-label={@close_label}
                  phx-click={Phoenix.LiveView.JS.exec("data-cancel", to: "##{@id}")}
                >
                  <%= render_slot(@close) %>
                  <span :if={@close == []}>close</span>
                </button>
                <h2 id={"#{@id}-title"}><%= render_slot(@title) %></h2>
              </header>
              <div id={"#{@id}-content"} class="modal-content">
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
        <nav class={[@base_class | @modifier_classes]} aria-label={@label} {@rest}>
          <div :if={@brand != []} class="navbar-brand">
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
        <ul class={[@base_class | @modifier_classes]} {@rest}>
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
    type: :component,
    since: "0.6.0",
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
        <header class={[@base_class | @modifier_classes]} {@rest}>
          <div class="page-header-title">
            <h1><%= @title %></h1>
            <p :if={@subtitle}><%= @subtitle %></p>
          </div>
          <div :if={@action != []} class="page-header-actions">
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
    type: :component,
    since: "0.6.0",
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
        <dl class={[@base_class | @modifier_classes]} {@rest}>
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
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
  def radio(%{option_value: _} = assigns) do
    ~H"""
    <Doggo.label>
      <input
        type="radio"
        name={@name}
        id={@id <> "_#{@option_value}"}
        value={@option_value}
        checked={Doggo.checked?(@option_value, @value)}
        aria-describedby={Doggo.input_aria_describedby(@id, @description)}
        aria-errormessage={Doggo.input_aria_errormessage(@id, @errors)}
        aria-invalid={@errors != [] && "true"}
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
    type: :component,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
      end,
    heex:
      quote do
        ~H"""
        <div class={[@base_class | @modifier_classes]} {@rest}></div>
        """
      end
  )

  component(
    :split_pane,
    modifiers: [],
    doc: """
    Renders a horizontal or vertical resizable split pane.

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Resize panes with the mouse
    > - Resize panes with the keyboard
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
    type: :component,
    since: "0.6.0",
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
        <div
          id={@id}
          class={[@base_class | @modifier_classes]}
          data-orientation={@orientation}
          {@rest}
        >
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
      upcoming_class: "is-upcoming"
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

      quote do
        var!(assigns) =
          assign(var!(assigns),
            current_class: unquote(current_class),
            completed_class: unquote(completed_class),
            upcoming_class: unquote(upcoming_class)
          )

        ~H"""
        <nav aria-label={@label} class={[@base_class | @modifier_classes]} {@rest}>
          <ol>
            <Doggo.Components.step
              :for={{step, index} <- Enum.with_index(@step)}
              step={step}
              index={index}
              current_step={@current_step}
              current_class={@current_class}
              completed_class={@completed_class}
              upcoming_class={@upcoming_class}
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
      <span :if={@index < @current_step} class="is-visually-hidden">
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
          type="button"
          role="switch"
          aria-checked={to_string(@checked)}
          {@rest}
        >
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
    type: :component,
    since: "0.6.0",
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
          assign(
            var!(assigns),
            :recursive_class,
            var!(assigns)[:recursive] && unquote(recursive_class)
          )

        ~H"""
        <div class={[@base_class | @modifier_classes] ++ [@recursive_class]} {@rest}>
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
        <nav aria-label={@label} class={[@base_class | @modifier_classes]} {@rest}>
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
    type: :component,
    since: "0.6.0",
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
        <div class={[@base_class | @modifier_classes]} {@rest}>
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Roving tabindex
    > - Move focus with arrow keys
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
    type: :component,
    since: "0.6.0",
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
        <div id={@id} class={[@base_class | @modifier_classes]} {@rest}>
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
    type: :component,
    since: "0.6.0",
    attrs_and_slots:
      quote do
        attr :rest, :global, doc: "Any additional HTML attributes."
        slot :inner_block, required: true
      end,
    heex:
      quote do
        ~H"""
        <span class={[@base_class | @modifier_classes]} {@rest}>
          <%= render_slot(@inner_block) %>
        </span>
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
    type: :button,
    since: "0.6.0",
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
        ~H"""
        <button
          type="button"
          phx-click={
            Phoenix.LiveView.JS.toggle_attribute(
              @on_click,
              {"aria-pressed", "true", "false"}
            )
          }
          aria-pressed={to_string(@pressed)}
          class={[@base_class | @modifier_classes]}
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Roving tabindex
    > - Move focus with arrow keys
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing features**
    >
    > - Expand and collapse nodes
    > - Select nodes
    > - Navigate tree with arrow keys

    ## CSS

    You can target the wrapper with an attribute selector for the role:

    ```css
    [role="tree"] {}
    ```
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
    """,
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
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

    > #### In Development {: .warning}
    >
    > The necessary JavaScript for making this component fully functional and
    > accessible will be added in a future version.
    >
    > **Missing featumres**
    >
    > - Expand and collapse nodes
    > - Select nodes
    > - Navigate tree with arrow keys
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
    type: :component,
    since: "0.6.0",
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
          class={[@base_class | @modifier_classes]}
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

  @doc false
  def modifier_classes(modifier_names, class_name_fun, assigns) do
    for name <- modifier_names do
      case assigns do
        %{^name => value} when is_binary(value) -> class_name_fun.(value)
        _ -> nil
      end
    end
  end
end
