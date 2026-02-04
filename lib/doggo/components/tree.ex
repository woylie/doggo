defmodule Doggo.Components.Tree do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a hierarchical list as a tree.

    A good use case for this component is a folder structure. For navigation and
    other menus, a regular nested list should be preferred.
    """
  end

  @impl true
  def usage do
    """
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

      **Missing features**

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
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".tree", "Dog Breeds")

    ~H"""
    <ul
      class={@class}
      role="tree"
      aria-label={@label}
      aria-labelledby={@labelledby}
      {@data_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end
end
