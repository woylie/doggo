defmodule Doggo.Components.Navbar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a navigation bar.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.navbar>
      <:brand><.link navigate={~p"/"}>Pet Clinic</.link></:brand>
      <.navbar_items>
        <:item><.link navigate={~p"/about"}>About</.link></:item>
        <:item><.link navigate={~p"/services"}>Services</.link></:item>
        <:item>
          <.link navigate={~p"/login"} class="button">Log in</.link>
        </:item>
      </.navbar_items>
    </.navbar>
    ```

    You can place multiple navigation item lists in the inner block. If the
    `.navbar` is styled as a flex box, you can use the CSS `order` property to
    control the display order of the brand and lists.

    ```heex
    <.navbar>
      <:brand><.link navigate={~p"/"}>Pet Clinic</.link></:brand>
      <.navbar_items class="navbar-main-links">
        <:item><.link navigate={~p"/about"}>About</.link></:item>
        <:item><.link navigate={~p"/services"}>Services</.link></:item>
      </.navbar_items>
      <.navbar_items class="navbar-user-menu">
        <:item>
          <.button_link navigate={~p"/login"}>Log in</.button_link>
        </:item>
      </.navbar_items>
    </.navbar>
    ```

    If you have multiple `<nav>` elements on your page, it is recommended to set
    the `aria-label` attribute.

    ```heex
    <.navbar aria-label="main navigation">
      <!-- ... -->
    </.navbar>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :developing,
      modifiers: []
    ]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :label, :string,
        required: true,
        doc: """
        Aria label for the `<nav>` element (e.g. "Main"). The label is especially
        important if you have multiple `<nav>` elements on the same page. If the
        page is localized, the label should be translated, too. Do not include
        "navigation" in the label, since screen readers will already announce the
        "navigation" role as part of the label.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :brand, doc: "Slot for the brand name or logo."

      slot :inner_block,
        required: true,
        doc: """
        Slot for navbar items. Use the `navbar_items` component here to render
        navigation links or other controls.
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
    <nav class={@class} aria-label={@label} {@rest}>
      <div :if={@brand != []} class={"#{@base_class}-brand"}>
        <%= render_slot(@brand) %>
      </div>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end
end
