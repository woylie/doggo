defmodule Doggo.Components.AppBar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    The app bar is typically located at the top of the interface and provides
    access to key features and navigation options.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.app_bar title="Page title">
      <:navigation label="Open menu" on_click={JS.push("toggle-menu")}>
        <.icon><Lucideicons.menu aria-hidden /></.icon>
      </:navigation>
      <:action label="Search" on_click={JS.push("search")}>
        <.icon><Lucideicons.search aria-hidden /></.icon>
      </:action>
      <:action label="Like" on_click={JS.push("like")}>
        <.icon><Lucideicons.heart aria-hidden /></.icon>
      </:action>
    </.app_bar>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :experimental,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-actions",
      "#{base_class}-navigation"
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :title, :string,
        default: nil,
        doc: "The page title. Will be set as `h1`."

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :navigation,
        doc: """
        Slot for a single button left of the title, typically used for a menu button
        that toggles a drawer, or for a back link.
        """ do
        attr :label, :string, required: true

        attr :on_click, :any,
          required: true,
          doc: "Event name or `Phoenix.LiveView.JS` command."
      end

      slot :action, doc: "Slot for action buttons right of the title." do
        attr :label, :string, required: true

        attr :on_click, :any,
          required: true,
          doc: "Event name or `Phoenix.LiveView.JS` command."
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
    <header class={@class} {@rest}>
      <div :if={@navigation != []} class={"#{@base_class}-navigation"}>
        <.link
          :for={navigation <- @navigation}
          phx-click={navigation.on_click}
          title={navigation.label}
        >
          {render_slot(navigation)}
        </.link>
      </div>
      <h1 :if={@title}>{@title}</h1>
      <div :if={@action != []} class={"#{@base_class}-actions"}>
        <.link
          :for={action <- @action}
          phx-click={action.on_click}
          title={action.label}
        >
          {render_slot(action)}
        </.link>
      </div>
    </header>
    """
  end
end
