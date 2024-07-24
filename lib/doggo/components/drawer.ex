defmodule Doggo.Components.Drawer do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a drawer with a `brand`, `top`, and `bottom` slot.

    All slots are optional, and you can render any content in them. If you want
    to use the drawer as a sidebar, you can use the `vertical_nav/1` and
    `vertical_nav_section/1` components.
    """
  end

  @impl true
  def usage do
    """
    Minimal example:

    ```heex
    <.drawer>
      <:main>Content</:main>
    </.drawer>
    ```

    With all slots:

    ```heex
    <.drawer>
      <:header>Doggo</:header>
      <:main>Content at the top</:main>
      <:footer>Content at the bottom</:footer>
    </.drawer>
    ```

    With navigation and sections:

    ```heex
    <.drawer>
      <:header>
        <.link navigate={~p"/"}>App</.link>
      </:header>
      <:main>
        <.vertical_nav label="Main">
          <:item>
            <.link navigate={~p"/dashboard"}>Dashboard</.link>
          </:item>
          <:item>
            <.vertical_nav_nested>
              <:title>Content</:title>
              <:item current_page>
                <.link navigate={~p"/posts"}>Posts</.link>
              </:item>
              <:item>
                <.link navigate={~p"/comments"}>Comments</.link>
              </:item>
            </.vertical_nav_nested>
          </:item>
        </.vertical_nav>
        <.vertical_nav_section>
          <:title>Search</:title>
          <:item><input type="search" placeholder="Search" /></:item>
        </.vertical_nav_section>
      </:main>
      <:footer>
        <.vertical_nav label="User menu">
          <:item>
            <.link navigate={~p"/settings"}>Settings</.link>
          </:item>
          <:item>
            <.link navigate={~p"/logout"}>Logout</.link>
          </:item>
        </.vertical_nav>
      </:footer>
    </.drawer>
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
  def attrs_and_slots do
    quote do
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :header, doc: "Optional slot for the brand name or logo."

      slot :main,
        doc: """
        Slot for content that is rendered after the brand, at the start of the
        side bar.
        """

      slot :footer,
        doc: """
        Slot for content that is rendered at the end of the drawer, potentially
        pinned to the bottom, if there is enough room.
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
    <aside class={@class} {@rest}>
      <div :if={@header != []} class={"#{@base_class}-header"}>
        <%= render_slot(@header) %>
      </div>
      <div :if={@main != []} class={"#{@base_class}-main"}>
        <%= render_slot(@main) %>
      </div>
      <div :if={@footer != []} class={"#{@base_class}-footer"}>
        <%= render_slot(@footer) %>
      </div>
    </aside>
    """
  end
end
