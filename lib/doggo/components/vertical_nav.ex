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
    """
  end

  @impl true
  def usage do
    """
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
    """
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

      attr :label, :string,
        default: nil,
        doc: """
        The aria label for the `<nav>` element. Not needed when the `:title`
        slot is filled: the title labels the navigation then.

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
        attr :class, :string
        attr :current_page, :boolean
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def example_label, do: "Main"

  @impl true
  def render(%{title: []} = assigns) do
    render_nav(assigns)
  end

  def render(assigns), do: render_nav(assigns)

  defp render_nav(assigns) do
    ~H"""
    <nav
      class={@class}
      id={@id}
      aria-label={@title == [] && @label}
      aria-labelledby={(@title != [] && "#{@id}-title") || @labelledby}
      {@data_attrs}
      {@rest}
    >
      <div :if={@title != []} id={"#{@id}-title"} class={"#{@base_class}-title"}>
        {render_slot(@title)}
      </div>
      <ul>
        <li
          :for={item <- @item}
          class={item[:class]}
          aria-current={item[:current_page] && "page"}
        >
          {render_slot(item)}
        </li>
      </ul>
    </nav>
    """
  end
end
