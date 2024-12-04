defmodule Doggo.Components.BottomNavigation do
  @moduledoc false

  @behaviour Doggo.Component

  use Phoenix.Component

  @impl true
  def doc do
    """
    Renders a navigation that sticks to the bottom of the screen.
    """
  end

  @impl true
  def usage do
    """
    ```heex
    <.bottom_navigation current_value={@view}>
      <:item
        label="Profile"
        navigate={~p"/pets/\#{@pet}"}
        value={Profile}
      >
        <Lucideicons.user aria-hidden="true" />
      </:item>
      <:item
        label="Appointments"
        navigate={~p"/pets/\#{@pet}/appointments"}
        value={Appointments}
      >
        <Lucideicons.calendar_days aria-hidden="true" />
      </:item>
      <:item
        label="Messages"
        navigate={~p"/pets/\#{@pet}/messages"}
        value={Messages}
      >
        <Lucideicons.mails aria-hidden="true" />
      </:item>
    </.bottom_navigation>
    ```
    """
  end

  @impl true
  def config do
    [
      type: :navigation,
      since: "0.6.0",
      maturity: :experimental,
      modifiers: []
    ]
  end

  @impl true
  def nested_classes(base_class) do
    ["#{base_class}-icon"]
  end

  @impl true
  def attrs_and_slots do
    quote do
      attr :label, :string,
        default: nil,
        doc: """
        Label for the `<nav>` element. The label is especially important if you have
        multiple `<nav>` elements on the same page. If the page is localized, the
        label should be translated, too. Do not include "navigation" in the label,
        since screen readers will already announce the "navigation" role as part
        of the label.
        """

      attr :current_value, :any,
        required: true,
        doc: """
        The current value used to compare the item values with. This could be the
        current LiveView module, or the live action.
        """

      attr :hide_labels, :boolean,
        default: false,
        doc: """
        Hides the labels of the individual navigation items.
        """

      attr :rest, :global, doc: "Any additional HTML attributes."

      slot :item,
        required: true,
        doc: """
        Slot for the navigation items. The inner content should be used to render an
        icon.
        """ do
        attr :label, :string,
          doc: """
          Required label for the navigation items. The item labels can be visually
          hidden with the `hide_labels` attribute on the component.
          """

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
            aria-label={item.label}
          >
            <span class={"#{@base_class}-icon"}>{render_slot(item)}</span>
            <span :if={!@hide_labels}>{item.label}</span>
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
