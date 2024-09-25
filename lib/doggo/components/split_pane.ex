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
    Horizontal separator with label:

    ```heex
    <.split_pane
      id="sidebar-splitter"
      label="Sidebar"
      orientation="horizontal"
    >
      <:primary>One</:primary>
      <:secondary>Two</:secondary>
    </.split_pane>
    ```

    Horizontal separator with visible label:

    ```heex
    <.split_pane id="sidebar-splitter"
      labelledby="sidebar-label"
      orientation="horizontal"
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
      orientation="horizontal"
    >
      <:primary>One</:primary>
      <:secondary>
        <.split_pane
          id="filter-splitter"
          label="Filters"
          orientation="vertical"
        >
          <:primary>Two</:primary>
          <:secondary>Three</:secondary>
        </.split_pane>
      </:secondary>
    </.split_pane>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Resize panes with the mouse
      - Resize panes with the keyboard
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
        required: true

      attr :default_size, :integer, required: true
      attr :min_size, :integer, default: 0
      attr :max_size, :integer, default: 100
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
    <div id={@id} class={@class} data-orientation={@orientation} {@rest}>
      <div id={"#{@id}-primary"}><%= render_slot(@primary) %></div>
      <div
        role="separator"
        aria-label={@label}
        aria-labelledby={@labelledby}
        aria-controls={"#{@id}-primary"}
        aria-orientation={@orientation}
        aria-valuenow={@default_size}
        aria-valuemin={@min_size}
        aria-valuemax={@max_size}
      >
      </div>
      <div id={"#{@id}-secondary"}><%= render_slot(@secondary) %></div>
    </div>
    """
  end
end
