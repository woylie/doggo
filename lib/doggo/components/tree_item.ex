defmodule Doggo.Components.TreeItem do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a tree item within a `tree/1`.

    This component can be used as a direct child of `tree/1` or within the `items`
    slot of this component.
    """
  end

  @impl true
  def usage do
    """
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

    ```heex
    <.tree_item>
      <Heroicon.folder /> Breeds
      <:items>
        <.tree_item><Heroicon.document /> Golden Retriever</.tree_item>
        <.tree_item><Heroicon.document /> Labrador Retriever</.tree_item>
      </:items>
    </.tree_item>
    ```
    """
  end

  @impl true
  def config do
    [
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
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
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
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
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
end
