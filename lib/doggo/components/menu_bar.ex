defmodule Doggo.Components.MenuBar do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a menu bar, similar to those found in desktop applications.

    This component is meant for organizing actions within an application, rather
    than for navigating between different pages or sections of a website.

    See also `menu/1`, `menu_group/1`, `menu_button/1`, `menu_item/1`, and
    `menu_item_checkbox/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.menu_bar label="Main">
      <:item>
        <.menu_button controls="actions-menu" id="actions-button">
          Actions
        </.menu_button>

        <.menu id="actions-menu" labelledby="actions-button" hidden>
          <:item>
            <.menu_item on_click={JS.push("view-dog-profiles")}>
              View Dog Profiles
            </.menu_item>
          </:item>
          <:item>
            <.menu_item on_click={JS.push("add-dog-profile")}>
              Add Dog Profile
            </.menu_item>
          </:item>
          <:item>
            <.menu_item on_click={JS.push("dog-care-tips")}>
              Dog Care Tips
            </.menu_item>
          </:item>
        </.menu>
      </:item>
      <:item role="separator"></:item>
      <:item>
        <.menu_item on_click={JS.dispatch("myapp:help")}>
          Help
        </.menu_item>
      </:item>
    </.menu_bar>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :menu,
      since: "0.6.0",
      maturity: :experimental,
      maturity_note: """
      The necessary JavaScript for making this component fully functional and
      accessible will be added in a future version.

      **Missing features**

      - Focus management
      - keyboard support
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
        A accessibility label for the menubar. Set as `aria-label` attribute.

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :labelledby, :string,
        default: nil,
        doc: """
        The DOM ID of an element that labels this menu bar.

        Example:

        ```html
        <h3 id="dog-menu-label">Dog Actions</h3>
        <Doggo.menu_bar labelledby="dog-menu-label"></Doggo.menu_bar>
        ```

        You should ensure that either the `label` or the `labelledby` attribute is
        set.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :role, :string,
          values: ["none", "separator"],
          doc: """
          Sets the role of the list item. If the item has a menu item, group, menu
          item radio group or menu item checkbox as a child, use `"none"`. If you
          want to render a visual separator, use `"separator"`. The default is
          `"none"`.
          """
      end
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    Doggo.ensure_label!(assigns, ".menu_bar", "Dog Actions")

    ~H"""
    <ul
      class={@class}
      role="menubar"
      aria-label={@label}
      aria-labelledby={@labelledby}
      {@rest}
    >
      <li :for={item <- @item} role={item[:role] || "none"}>
        <%= if item[:role] != "separator" do %>
          {render_slot(item)}
        <% end %>
      </li>
    </ul>
    """
  end
end
