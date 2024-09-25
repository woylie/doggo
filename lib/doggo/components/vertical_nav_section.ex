defmodule Doggo.Components.VerticalNavSection do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a section within a sidebar or drawer that contains one or more
    items which are not navigation links.

    To render navigation links, use `vertical_nav/1` instead.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.vertical_nav_section>
      <:title>Search</:title>
      <:item><input type="search" placeholder="Search" /></:item>
    </.vertical_nav_section>
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
      "#{base_class}-item",
      "#{base_class}-title"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :id, :string, required: true

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :title, doc: "An optional slot for the title of the section."

      slot :item, required: true, doc: "Items" do
        attr :class, :any,
          doc: "Additional CSS classes. Can be a string or a list of strings."
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
end
