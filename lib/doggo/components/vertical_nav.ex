defmodule Doggo.Components.VerticalNav do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a vertical navigation menu.

    It is commonly placed within drawers or sidebars.

    For hierarchical menu structures, use `vertical_nav_nested/1` within the
    `:item` slot.

    To include sections in your drawer or sidebar that are not part of the
    navigation menu (like informational text or a site search), use the
    `vertical_nav_section/1` component.

    If the list is part of a navigation landmark you render yourself, set
    `landmark={false}`. The component then renders a `<div>` instead of a
    `<nav>`, and the label names the list.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.vertical_nav id="main-nav" label="Main">
      <:item>
        <.link navigate={~p"/dashboard"}>Dashboard</.link>
      </:item>
      <:item>
        <.vertical_nav_nested id="content-nav">
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

    Inside a navigation landmark:

    ```heex
    <nav aria-label="Main">
      <.vertical_nav id="project-nav" landmark={false}>
        <:title>Projects</:title>
        <:item>
          <.link navigate={~p"/projects/1"}>Adoption</.link>
        </:item>
      </.vertical_nav>
    </nav>
    ```
    """
  end

  @impl true
  def css_path do
    "components/vertical-nav.css"
  end

  @impl true
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-title"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true

      attr :landmark, :boolean,
        default: true,
        doc: """
        Renders the navigation as a `<nav>` landmark. Set it to `false` if the
        component is placed inside an existing navigation landmark. The
        component then renders a `<div>`, the label names the list instead,
        and a label is optional.
        """

      attr :label, :string,
        default: nil,
        doc: """
        The aria label for the `<nav>` element, or for the list if `landmark`
        is `false`. Not needed when the `:title` slot is filled: the title
        labels the navigation then.

        Do not repeat the word `navigation` in the label. Screen readers
        announce the role along with the name. Using the role in the label
        would make screen readers repeat it.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this navigation, for a heading the
        component does not render itself. Not needed when the `:title` slot is
        filled.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :title, doc: "An optional slot for the title of the menu."

      slot :item, required: true, doc: "Items" do
        attr :class, :any,
          doc: "Additional CSS classes. Can be a string or a list of strings."

        attr :current_page, :boolean
      end
    end
  end

  @impl true
  def init_block(opts, _extra) do
    name = ".#{Keyword.fetch!(opts, :name)}"

    quote do
      if var!(assigns).landmark do
        Doggo.ensure_label!(var!(assigns), unquote(name), "Main")
      end
    end
  end

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns,
        aria_label: assigns.title == [] && assigns.label,
        aria_labelledby:
          (assigns.title != [] && "#{assigns.id}-title") || assigns.labelledby
      )

    ~H"""
    <.dynamic_tag
      tag_name={if @landmark, do: "nav", else: "div"}
      class={@class}
      id={@id}
      aria-label={@landmark && @aria_label}
      aria-labelledby={@landmark && @aria_labelledby}
      {@data_attrs}
      {@rest}
    >
      <div :if={@title != []} id={"#{@id}-title"} class={"#{@base_class}-title"}>
        {render_slot(@title)}
      </div>
      <ul
        aria-label={!@landmark && @aria_label}
        aria-labelledby={!@landmark && @aria_labelledby}
      >
        <li
          :for={item <- @item}
          class={item[:class]}
          aria-current={item[:current_page] && "page"}
        >
          {render_slot(item)}
        </li>
      </ul>
    </.dynamic_tag>
    """
  end
end
