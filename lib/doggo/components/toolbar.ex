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
          <.icon label="Feed dog"><Icons.feed /></.icon>
        </button>
        <button phx-click="walk-dog">
          <.icon label="Walk dog"><Icons.walk /></.icon>
        </button>
      </div>
      <div role="group">
        <button phx-click="teach-trick">
          <.icon label="Teach a Trick"><Icons.teach /></.icon>
        </button>
        <button phx-click="groom-dog">
          <.icon label="Groom dog"><Icons.groom /></.icon>
        </button>
      </div>
    </.toolbar>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :miscellaneous,
      since: "0.6.0",
      maturity: :experimental,
      modifiers: [],
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Roving tabindex
      - Move focus with arrow keys
      """
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
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
      class={@class}
      role="toolbar"
      aria-label={@label}
      aria-labelledby={@labelledby}
      aria-controls={@controls}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
