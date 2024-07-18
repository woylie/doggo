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
        badge()
        box()
        breadcrumb()
        button()
        button_link()
        cluster()
        disclosure_button()
        fab()
        tag()
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
                phx-click={Doggo.Components.toggle_accordion_section(@id, index)}
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

  @doc false
  def toggle_accordion_section(id, index)
      when is_binary(id) and is_integer(index) do
    %Phoenix.LiveView.JS{}
    |> Phoenix.LiveView.JS.toggle_attribute({"aria-expanded", "true", "false"},
      to: "##{id}-trigger-#{index}"
    )
    |> Phoenix.LiveView.JS.toggle_attribute({"hidden", "hidden"},
      to: "##{id}-section-#{index}"
    )
  end

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
        Doggo.ensure_label!(var!(assigns), "tree", "Dog Breeds")

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
