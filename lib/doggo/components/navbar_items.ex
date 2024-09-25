defmodule Doggo.Components.NavbarItems do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a list of navigation items.

    Meant to be used in the inner block of the `navbar` component.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.navbar_items>
      <:item><.link navigate={~p"/about"}>About</.link></:item>
      <:item><.link navigate={~p"/services"}>Services</.link></:item>
      <:item>
        <.link navigate={~p"/login"} class="button">Log in</.link>
      </:item>
    </.navbar_items>
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
  def nested_classes(_) do
    []
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item,
        required: true,
        doc: "A navigation item, usually a link or a button." do
        attr :class, :string, doc: "A class for the `<li>`."
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
    <ul class={@class} {@rest}>
      <li :for={item <- @item} class={item[:class]}><%= render_slot(item) %></li>
    </ul>
    """
  end
end
