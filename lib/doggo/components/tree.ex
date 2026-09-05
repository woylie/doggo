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

    This component needs the `Doggo.Tree` JavaScript hook. See
    [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.
    """
  end

  @impl true
  def keyboard do
    """
    - `Down` and `Up` - move between the visible items. A collapsed branch takes
      its children out of the sequence.
    - `Right` - expand the focused branch, or move to its first child if it is
      already expanded.
    - `Left` - collapse the focused branch, or move to its parent if it is
      already collapsed or is a leaf.
    - `Home` and `End` - first and last visible item.
    - Printable characters - move to the next visible item whose label starts
      with what you type.

    The tree is a single tab stop. Expanding and collapsing is the hook's own
    state, and it survives a LiveView patch. Selecting an item is not: the
    component renders `aria-selected` from the `selected` attribute of
    `tree_item`, so wire your own click or key handler and re-render.
    """
  end

  @impl true
  def css_path do
    "components/_tree.scss"
  end

  @impl true
  def config do
    [
      type: :data,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      **Missing features**

      - Selecting a node. The component renders `aria-selected` from the
        `selected` attribute and never changes it, so the caller has to.
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
      attr :id, :string,
        required: true,
        doc: "A unique DOM ID. Needed for the JavaScript hook."

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
      id={@id}
      class={@class}
      role="tree"
      phx-hook="Doggo.Tree"
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
