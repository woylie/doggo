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
    <.navbar label="Main">
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
    <.navbar label="Main">
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

    If a visible heading already names the navigation, point `labelledby` at it
    instead of setting `label`.

    ```heex
    <h2 id="site-nav-heading">Pet Clinic</h2>
    <.navbar labelledby="site-nav-heading">
      <!-- ... -->
    </.navbar>
    ```
    """
  end

  @impl true
  def css_path do
    "components/navbar.css"
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
  def own_attributes, do: ["aria-label": :label]

  @impl true
  def nested_classes(base_class) do
    [
      "#{base_class}-brand"
    ]
  end

  @impl true
  def attrs_and_slots(_opts) do
    quote do
      attr :label, :string,
        default: nil,
        doc: """
        Aria label for the `<nav>` element (e.g. "Main"). The label is
        especially important if you have multiple `<nav>` elements on the same
        page. If the page is localized, the label should be translated, too. Do
        not include "navigation" in the label, since screen readers will already
        announce the "navigation" role as part of the label.

        Do not repeat the word `navigation` in the label. Screen readers
        announce the role along with the name. Using the role in the label
        would make screen readers repeat it.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this navigation.

        Set either this attribute or `label`.
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
  def example_label, do: "Main"

  @impl true
  def template(_opts) do
    quote do
      ~H"""
      <nav
        class={[Doggo.build(:base_class) | List.wrap(@class)]}
        aria-label={@label}
        aria-labelledby={@labelledby}
        {@data_attrs}
        {@rest}
      >
        <div :if={@brand != []} class={Doggo.build(:base_class, "-brand")}>
          {render_slot(@brand)}
        </div>
        {render_slot(@inner_block)}
      </nav>
      """
    end
  end
end
