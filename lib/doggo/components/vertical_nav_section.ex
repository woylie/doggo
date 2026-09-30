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
  def usage(%{name: name}) do
    """
    ```heex
    <.#{name} id="search-section">
      <:title>Search</:title>
      <:item><input type="search" placeholder="Search" /></:item>
    </.#{name}>
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
  def own_attributes, do: ["aria-labelledby": nil, role: nil]

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-item",
      "#{base_class}-title"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
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
  def template(_opts) do
    quote do
      ~H"""
      <div
        :if={@item != []}
        id={@id}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        role={@title != [] && "group"}
        aria-labelledby={@title != [] && "#{@id}-title"}
        {@data_attrs}
        {@rest}
      >
        <div
          :if={@title != []}
          id={"#{@id}-title"}
          class={Doggo.build(:base_class, "-title")}
        >
          {render_slot(@title)}
        </div>
        <div
          :for={item <- @item}
          class={[Doggo.build(:base_class, "-item") | List.wrap(item[:class] || [])]}
        >
          {render_slot(item)}
        </div>
      </div>
      """
    end
  end
end
