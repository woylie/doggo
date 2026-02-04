defmodule Doggo.Components.Menu do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a menu that offers a list of actions or functions.

    This component is meant for organizing actions within an application, rather
    than for navigating between different pages or sections of a website.

    See also `menu_bar/1`, `menu_group/1`, `menu_button/1`, `menu_item/1`, and
    `menu_item_checkbox/1`.
    """
  end

  @impl true
  def usage do
    """
    If the menu is always visible or can only be toggled by a keyboard shortcut,
    set the `label` attribute.

    ```heex
    <.menu label="Actions">
      <:item>Copy</:item>
      <:item>Paste</:item>
      <:item role="separator"></:item>
      <:item>Sort lines</:item>
    </.menu>
    ```

    If the menu is toggled by a `menu_button/1`, ensure that the `controls`
    attribute of the button matches the DOM ID of the menu and that the
    `labelledby` attribute of the menu matches the DOM ID of the button.

    <.menu_button controls="actions-menu" id="actions-button">
      Actions
    </.menu_button>
    <.menu labelledby="actions-button" hidden></.menu>
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
        The DOM ID of an element that labels this menubar. If the menu is toggled
        by a `menu_button/1`, this attribute should be set to the DOM ID of that
        button.

        Example:

        ```html
        <Doggo.menu_button controls="actions-menu" id="actions-button">
          Actions
        </Doggo.menu_button>
        <Doggo.menu labelledby="actions-button" hidden></Doggo.menu>
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
    Doggo.ensure_label!(assigns, ".menu", "Dog Actions")

    ~H"""
    <ul
      class={@class}
      role="menu"
      aria-label={@label}
      aria-labelledby={@labelledby}
      {@data_attrs}
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
