defmodule Doggo.Components.Drawer do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a drawer with a `header`, `body`, and `footer` slot.

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
    <.drawer id="drawer">
      <:body>Content</:body>
    </.drawer>
    ```

    With all slots:

    ```heex
    <.drawer id="drawer">
      <:header>Doggo</:header>
      <:body>Content at the top</:body>
      <:footer>Content at the bottom</:footer>
    </.drawer>
    ```

    With navigation and sections:

    ```heex
    <.drawer id="drawer">
      <:header>
        <.link navigate={~p"/"}>App</.link>
      </:header>
      <:body>
        <.vertical_nav id="main-nav" label="Main">
          <:item>
            <.link navigate={~p"/dashboard"}>Dashboard</.link>
          </:item>
          <:item>
            <.vertical_nav_nested id="content-nav">
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
        <.vertical_nav_section id="search">
          <:title>Search</:title>
          <:item><input type="search" placeholder="Search" /></:item>
        </.vertical_nav_section>
      </:body>
      <:footer>
        <.vertical_nav id="user-nav" label="User menu">
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

    ## Semantics

    With a `header`, the drawer renders `role="complementary"`, named by the
    header. Set `role` to choose another landmark:

    - `role="navigation"` for a drawer that is the site navigation. The header
      still names it.
    - `role={nil}` for a drawer that holds a `vertical_nav/1`, which is a
      navigation landmark of its own. The page then has no `complementary`
      landmark around it.

    Without a `header`, the drawer is no landmark unless you set `role`, and
    you name it with `aria-label`. With a `header`, the header names the
    drawer, and an `aria-label` has no effect.
    """
  end

  @impl true
  def css_path do
    "components/drawer.css"
  end

  @impl true
  def config do
    [
      type: :layout,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def own_attributes, do: ["aria-labelledby": nil]

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-footer",
      "#{base_class}-header",
      "#{base_class}-body"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :id, :string, required: true
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :header, doc: "Optional slot for the brand name or logo."

      slot :body,
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
  def template(_opts) do
    quote do
      ~H"""
      <div
        :if={@header != [] or @body != [] or @footer != []}
        id={@id}
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        role={Map.get(@rest, :role, @header != [] && "complementary")}
        aria-labelledby={
          Map.get(@rest, :role, true) && @header != [] && "#{@id}-header"
        }
        {@data_attrs}
        {Map.delete(@rest, :role)}
      >
        <div
          :if={@header != []}
          id={"#{@id}-header"}
          class={Doggo.build(:base_class, "-header")}
        >
          {render_slot(@header)}
        </div>
        <div :if={@body != []} class={Doggo.build(:base_class, "-body")}>
          {render_slot(@body)}
        </div>
        <div :if={@footer != []} class={Doggo.build(:base_class, "-footer")}>
          {render_slot(@footer)}
        </div>
      </div>
      """
    end
  end
end
