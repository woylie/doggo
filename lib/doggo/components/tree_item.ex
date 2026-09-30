defmodule Doggo.Components.TreeItem do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a tree item within a `tree/1`.

    This component can be used as a direct child of `tree/1` or within the
    `items` slot of this component.
    """
  end

  @impl true
  def usage(%{name: name}) do
    """
    ```heex
    <.tree id="dog-tree" label="Dogs">
      <.#{name}>
        Breeds
        <:items>
          <.#{name}>Golden Retriever</.#{name}>
          <.#{name}>Labrador Retriever</.#{name}>
        </:items>
      </.#{name}>
      <.#{name}>
        Characteristics
        <:items>
          <.#{name}>Playful</.#{name}>
          <.#{name}>Loyal</.#{name}>
        </:items>
      </.#{name}>
    </.tree>
    ```

    Icons can be added before the label:

    ```heex
    <.#{name}>
      <Heroicon.folder /> Breeds
      <:items>
        <.#{name}><Heroicon.document /> Golden Retriever</.#{name}>
        <.#{name}><Heroicon.document /> Labrador Retriever</.#{name}>
      </:items>
    </.#{name}>
    ```
    """
  end

  @impl true
  def css_path do
    "components/tree.css"
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :developing,
      maturity_note: """
      **Missing features**

      - Selecting a node. The component renders `aria-selected` from the
        `selected` attribute and never changes it, so the caller has to.
      """,
      modifiers: []
    ]
  end

  @impl true
  def own_attributes, do: ["aria-expanded": nil, role: nil]

  @impl true
  def nested_classes(base_class) do
    ["#{base_class}-label", "#{base_class}-toggle"]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :expanded, :boolean,
        default: true,
        doc: """
        Whether the children of this item are shown. Has no effect on a leaf
        node. When `false`, the child list is hidden and `aria-expanded` reports
        the item as collapsed.

        This is the initial state. Once the user has expanded or collapsed the
        item, a later value from the server does not change it.
        """

      attr :selected, :boolean,
        default: nil,
        doc: """
        If set to `true`, an `aria-selected` attribute is added.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :items,
        doc: """
        Slot for children of this item. Place one or more additional
        `tree_item/1` components within this slot, or omit if this is a leaf
        node.
        """

      slot :inner_block,
        required: true,
        doc: """
        Slot for the item label.
        """
    end
  end

  @impl true
  def template(_opts) do
    quote do
      ~H"""
      <li
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        role="treeitem"
        aria-selected={@selected != nil && to_string(@selected)}
        aria-expanded={@items != [] && to_string(@expanded)}
        {@data_attrs}
        {@rest}
      >
        <button
          :if={@items != []}
          type="button"
          class={Doggo.build(:base_class, "-toggle")}
          tabindex="-1"
          aria-hidden="true"
        ></button>
        <span class={Doggo.build(:base_class, "-label")}>{render_slot(@inner_block)}</span>
        <ul :if={@items != []} role="group" hidden={!@expanded}>
          {render_slot(@items)}
        </ul>
      </li>
      """
    end
  end
end
