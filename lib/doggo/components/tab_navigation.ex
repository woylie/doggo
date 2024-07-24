defmodule Doggo.Components.TabNavigation do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders navigation tabs.

    This component is meant for tabs that link to a different view or live action.
    If you want to render tabs that switch between in-page content panels, use
    `tabs/1` instead.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.tab_navigation current_value={@live_action}>
      <:item
        patch={~p"/pets/\#{@pet}"}
        value={[:show, :edit]}
      >
        Profile
      </:item>
      <:item
        patch={~p"/pets/\#{@pet}/appointments"}
        value={:appointments}
      >
        Appointments
      </:item>
      <:item
        patch={~p"/pets/\#{@pet}/messages"}
        value={:messages}
      >
        Messages
      </:item>
    </.tab_navigation>
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
        default: "Tabs",
        doc: """
        Aria label for the `<nav>` element. The label is especially important if you
        have multiple `<nav>` elements on the same page. If the page is localized,
        the label should be translated, too. Do not include "navigation" in the
        label, since screen readers will already announce the "navigation" role as
        part of the label.
        """

      attr :current_value, :any,
        required: true,
        doc: """
        The current value used to compare the item values with. If you use this
        component to patch between different view actions, this could be the
        `@live_action` attribute.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item, required: true do
        attr :href, :string, doc: "Passed to `Phoenix.Component.link/1`."
        attr :navigate, :string, doc: "Passed to `Phoenix.Component.link/1`."
        attr :patch, :string, doc: "Passed to `Phoenix.Component.link/1`."

        attr :value, :any,
          doc: """
          The value of the item is compared to the `current_value` attribute to
          determine whether to add the `aria-current` attribute. This can be a
          single value or a list of values, e.g. multiple live actions for which
          the item should be marked as current.
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
    <nav aria-label={@label} class={@class} {@rest}>
      <ul>
        <li :for={item <- @item}>
          <.link
            href={item[:href]}
            navigate={item[:navigate]}
            patch={item[:patch]}
            aria-current={@current_value in List.wrap(item.value) && "page"}
          >
            <%= render_slot(item) %>
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
