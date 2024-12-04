defmodule Doggo.Components.MenuButton do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a button that toggles an actions menu.

    This component can be used on its own or as part of a `menu_bar/1` or `menu/1`.
    See also `menu_item/1`, `menu_item_checkbox/1`, and `menu_group/1`.

    For a button that toggles the visibility of an element that is not a menu, use
    `disclosure_button/1`. For a button that toggles other states, use
    `toggle_button/1`. See also `button/1` and `button_link/1`.
    """
  end

  @impl true
  def usage do
    """
    Set the `controls` attribute to the DOM ID of the element that you want to
    toggle with the button.

    The initial state is hidden. Do not forget to add the `hidden` attribute to
    the toggled menu. Otherwise, visibility of the element will not align with
    the `aria-expanded` attribute of the button.

    ```heex
    <div>
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
    </div>
    ```

    If this menu button is a child of a `menu_bar/1` or a `menu/1`, set the
    `menuitem` attribute.

    ```heex
    <.menu id="actions-menu">
      <:item>
        <.menu_button controls="actions-menu" id="actions-button" menuitem>
          Dog Actions
        </.menu_button>
        <.menu id="dog-actions-menu" labelledby="actions-button" hidden>
          <:item><!-- ... --></:item>
        </.menu>
      </:item>
      <:item><!-- ... --></:item>
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
      attr :id, :string,
        required: true,
        doc: """
        The DOM ID of the button. Set the `aria-labelledby` attribute of the toggled
        menu to the same value.
        """

      attr :controls, :string,
        required: true,
        doc: """
        The DOM ID of the element that this button controls.
        """

      attr :menuitem, :boolean,
        default: false,
        doc: """
        Set this attribute to `true` if the menu button is used as a child of a
        `menu_bar/1`. This ensures that the `role` is set to `menuitem`.
        """

      attr :rest, :global

      slot :inner_block, required: true
    end
  end

  @impl true
  def init_block(_opts, _extra) do
    []
  end

  @impl true
  def render(assigns) do
    ~H"""
    <button
      class={@class}
      id={@id}
      type="button"
      role={@menuitem && "menuitem"}
      aria-haspopup="true"
      aria-expanded="false"
      aria-controls={@controls}
      phx-click={Doggo.toggle_disclosure(@controls)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
