defmodule Doggo.Components.MenuGroup do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    This component can be used to group items within a `menu/1` or `menu_bar/1`.

    See also `menu_button/1`, `menu_item/1`, and `menu_item_checkbox/1`.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.menu id="actions-menu" labelledby="actions-button" hidden>
      <:item>
        <.menu_group label="Dog actions">
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
        </.menu_group>
      </:item>
      <:item role="separator" />
      <:item>
        <.menu_item on_click={JS.push("help")}>Help</.menu_item>
      </:item>
    </.menu>
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
      - Keyboard support
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
        required: true,
        doc: """
        A accessibility label for the group. Set as `aria-label` attribute.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :role, :string,
          values: ["none", "separator"],
          doc: """
          Sets the role of the list item. If the item has a menu item, menu
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
    ~H"""
    <ul class={@class} role="group" aria-label={@label} {@rest}>
      <li :for={item <- @item} role={item[:role] || "none"}>
        <%= if item[:role] != "separator" do %>
          {render_slot(item)}
        <% end %>
      </li>
    </ul>
    """
  end
end
