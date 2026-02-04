defmodule Doggo.Components.VerticalNavNested do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders nested navigation items within the `:item` slot of the
    `vertical_nav/1` component.
    """
  end

  @impl true
  def usage do
    """
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
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :title,
        doc: "An optional slot for the title of the nested menu section."

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
  def render(assigns) do
    ~H"""
    <div class={@class} {@data_attrs} {@rest}>
      <div :if={@title != []} id={"#{@id}-title"} class={"#{@base_class}-title"}>
        {render_slot(@title)}
      </div>
      <ul id={@id} aria-labelledby={@title != [] && "#{@id}-title"}>
        <li
          :for={item <- @item}
          class={item[:class]}
          aria-current={item[:current_page] && "page"}
        >
          {render_slot(item)}
        </li>
      </ul>
    </div>
    """
  end
end
