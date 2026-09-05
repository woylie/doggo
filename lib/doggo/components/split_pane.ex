defmodule Doggo.Components.SplitPane do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a horizontal or vertical resizable split pane.
    """
  end

  @impl true
  def usage do
    """
    Vertical separator with label:

    ```heex
    <.split_pane
      id="sidebar-splitter"
      label="Sidebar"
      orientation="vertical"
      default_size={30}
    >
      <:primary>One</:primary>
      <:secondary>Two</:secondary>
    </.split_pane>
    ```

    Vertical separator with visible label:

    ```heex
    <.split_pane id="sidebar-splitter"
      labelledby="sidebar-label"
      orientation="vertical"
      default_size={30}
    >
      <:primary>
        <h2 id="sidebar-label">Sidebar</h2>
        <p>One</p>
      </:primary>
      <:secondary>Two</:secondary>
    </.split_pane>
    ```

    Nested window splitters:

    ```heex
    <.split_pane
      id="sidebar-splitter"
      label="Sidebar"
      orientation="vertical"
      default_size={30}
    >
      <:primary>One</:primary>
      <:secondary>
        <.split_pane
          id="filter-splitter"
          label="Filters"
          orientation="horizontal"
          default_size={50}
        >
          <:primary>Two</:primary>
          <:secondary>Three</:secondary>
        </.split_pane>
      </:secondary>
    </.split_pane>
    ```

    The size of the primary pane is written to the `--split-pane-position`
    custom property on the outer element as a percentage. Your stylesheet must
    apply that property to the layout.

    A split pane with a horizontal separator needs a height of its own, or both
    panes stay at the size of their content.
    """
  end

  @impl true
  def keyboard do
    """
    - `Left` and `Right` - move a vertical separator by one percent.
    - `Up` and `Down` - move a horizontal separator by one percent.
    - `Shift` + arrow key - move by ten percent.
    - `Home` and `End` - the smallest and the largest size.
    - `Enter` - collapse the primary pane, or restore the size it had before.

    The size is the hook's own state and it survives a LiveView patch, so
    `default_size` applies on the first render only.
    """
  end

  @impl true
  def css_path do
    "components/_split-pane.scss"
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      **Missing features**

      - Reporting the size to the server, so that it can be persisted
      - Snapping to preset positions
      - Choosing which pane keeps its size when the split pane itself is
        resized
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
        An accessibility label for the separator if the primary pane has no visible
        label. If it has a visible label, set the `labelledby` attribute instead.

        Note that the label should describe the primary pane, not the resize handle.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        If the primary pane has a visible label, set this attribute to the DOM ID
        of that label. Otherwise, provide a label via the `label` attribute.
        """

      attr :id, :string, required: true

      attr :orientation, :string,
        values: ["horizontal", "vertical"],
        required: true,
        doc: """
        The orientation of the separator, not of the panes: a `vertical`
        separator stands between two panes side by side, a `horizontal` one
        between two panes above each other.
        """

      attr :default_size, :integer,
        required: true,
        doc: """
        The size of the primary pane in percent on the first render.
        """

      attr :min_size, :integer,
        default: 0,
        doc: "The smallest size of the primary pane in percent."

      attr :max_size, :integer,
        default: 100,
        doc: "The largest size of the primary pane in percent."

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :primary, required: true
      slot :secondary, required: true
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".split_pane", "Sidebar")

    ~H"""
    <div
      id={@id}
      class={@class}
      data-orientation={@orientation}
      phx-hook="Doggo.SplitPane"
      {@data_attrs}
      {@rest}
    >
      <div id={"#{@id}-primary"}>{render_slot(@primary)}</div>
      <div
        role="separator"
        tabindex="0"
        aria-label={@label}
        aria-labelledby={@labelledby}
        aria-controls={"#{@id}-primary"}
        aria-orientation={@orientation}
        aria-valuenow={@default_size}
        aria-valuemin={@min_size}
        aria-valuemax={@max_size}
      >
      </div>
      <div id={"#{@id}-secondary"}>{render_slot(@secondary)}</div>
    </div>
    """
  end
end
