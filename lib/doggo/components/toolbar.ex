defmodule Doggo.Components.Toolbar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a container for a set of controls.
    """
  end

  @impl true
  def usage do
    """
    Direct children of this component can be any types buttons or groups of
    buttons.

    ```heex
    <.toolbar label="Actions for the dog">
      <div role="group">
        <button phx-click="feed-dog">
          <.icon text="Feed dog"><Icons.feed /></.icon>
        </button>
        <button phx-click="walk-dog">
          <.icon text="Walk dog"><Icons.walk /></.icon>
        </button>
      </div>
      <div role="group">
        <button phx-click="teach-trick">
          <.icon text="Teach a Trick"><Icons.teach /></.icon>
        </button>
        <button phx-click="groom-dog">
          <.icon text="Groom dog"><Icons.groom /></.icon>
        </button>
      </div>
    </.toolbar>
    ```

    This component needs the `Doggo.Toolbar` JavaScript hook. See
    [Phoenix LiveView Hooks](readme.html#phoenix-liveview-hooks) for
    registering it.
    """
  end

  @impl true
  def keyboard do
    """
    - `Left` and `Right` - move between the controls, wrapping at the ends. A
      toolbar with `orientation="vertical"` uses `Up` and `Down` instead.
    - `Home` and `End` - first and last control.

    The toolbar is a single tab stop. `Tab` moves to the control the user last
    used, and the arrow keys move between them.
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :experimental,
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
        doc: "A unique DOM ID. The JavaScript hook needs it."

      attr :orientation, :string,
        default: "horizontal",
        values: ["horizontal", "vertical"],
        doc: """
        Sets `aria-orientation` and determines whether to use the left and right
        arrow keys or the up and down arrow keys to move between controls.
        """

      attr :label, :string,
        default: nil,
        doc: """
        A accessibility label for the toolbar. Set as `aria-label` attribute.

        You should ensure that either the `label` or the `labelledby` attribute is
        set.

        Do not repeat the word `toolbar` in the label, since it is already announced
        by screen readers.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this tree.

        Example:

        ```html
        <h3 id="dog-toolbar-label">Dogs</h3>
        <Doggo.toolbar labelledby="dog-toolbar-label"></Doggo.toolbar>
        ```

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :controls, :string,
        default: nil,
        doc: """
        DOM ID of the element that is controlled by this toolbar. For example,
        if the toolbar provides text formatting options for an editable content
        area, the values should be the ID of that content area.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :inner_block,
        required: true,
        doc: """
        Place any number of buttons, groups of buttons, toggle buttons, menu
        buttons, or disclosure buttons here.
        """
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".toolbar", "Dog profile actions")

    ~H"""
    <div
      id={@id}
      class={@class}
      role="toolbar"
      aria-label={@label}
      aria-labelledby={@labelledby}
      aria-controls={@controls}
      aria-orientation={@orientation == "vertical" && "vertical"}
      phx-hook="Doggo.Toolbar"
      {@data_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
